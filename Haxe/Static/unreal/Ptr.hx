package unreal;

/**
  Represents a pointer (SomeType *) that can be assigned
**/
@:unrealType
@:forward
abstract Ptr<T>(PtrMacros<T>) {
  /**
    Creates a reference of the target type in the stack. The reference is only guaranteed to be
    alive 
  **/
  macro public static function createStack<T>():haxe.macro.Expr.ExprOf<Ref<T>> {
    return PtrMacros.createStackHelper(false);
  }

#if (!macro && !bake_externs)

  public static function fromStruct<T : Struct>(struct : Struct):Ref<T> {
    return cast uhx.internal.Helpers.getWrapperPointer(struct);
  }

  /**
    Adds the `offset` amount in bytes to the current address. Note that this adds the value in bytes
  **/
  @:extern inline public function addOffset(bytesOffset:Int):Ptr<T> {
    return cast this.addOffset(bytesOffset);
  }

#end
}