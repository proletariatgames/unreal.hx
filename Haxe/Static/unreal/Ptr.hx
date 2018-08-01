package unreal;

/**
  Represents a pointer (SomeType *) that can be assigned by the external C++ code.
  This is used as a `PPtr` replacement for basic types, or to represent more exotic types
  such as `SomeType **`
**/
@:unrealType
@:forward
abstract Ptr<T>(PtrMacros<T>) {
  /**
    Creates a reference of the target type in the stack. The reference is only guaranteed to be
    alive when it is used as a local variable - so be aware not to store the result in a way
    that will outlive the stack's lifetime
  **/
  macro public static function createStack<T>():haxe.macro.Expr.ExprOf<Ref<T>> {
    return PtrMacros.createStackHelper(false);
  }

#if (!macro && !bake_externs)

  /**
    Creates the equivalent of a `nullptr`
  **/
  public static function mkNull<T>():Ptr<T> {
    return cast 0;
  }

  /**
    Creates a `Ptr<T>` from a struct
  **/
  public static function fromStruct<T : Struct>(struct : Struct):Ptr<T> {
    return cast uhx.internal.HaxeHelpers.getUnderlyingPointer(struct);
  }

  /**
    Adds the `offset` amount in bytes to the current address. Note that this adds the value in bytes
  **/
  @:extern inline public function addOffset(bytesOffset:Int):Ptr<T> {
    return cast this.addOffset(bytesOffset);
  }

#end
}