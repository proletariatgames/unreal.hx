package unreal;

/**
  Represents a reference (SomeType&) that can be assigned by the external C++ code
**/
@:unrealType
@:forward
abstract Ref<T>(PtrMacros<T>) {
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
    Casts an `AnyPtr` object to `Ref`
  **/
  inline public static function fromAnyPtr<T>(ptr:AnyPtr):Ref<T> {
    return cast ptr;
  }

  /**
    Casts to `AnyPtr`
  **/
  inline public function toAnyPtr():AnyPtr {
    return cast this;
  }

  /**
    Creates the equivalent of a `nullptr`
  **/
  public static function mkNull<T>():Ref<T> {
    return cast 0;
  }

  /**
    Creates a `Ref<T>` from a struct
  **/
  public static function fromStruct<T : Struct>(struct : Struct):Ref<T> {
    return cast uhx.internal.HaxeHelpers.getUnderlyingPointer(struct);
  }

  /**
    Adds the `offset` amount in bytes to the current address. Note that this adds the value in bytes
  **/
  @:extern inline public function addOffset(bytesOffset:Int):Ref<T> {
    return cast this.addOffset(bytesOffset);
  }

#end
}