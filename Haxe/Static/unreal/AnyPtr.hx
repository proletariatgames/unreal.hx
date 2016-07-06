package unreal;

@:forward
abstract AnyPtr(UIntPtr) from UIntPtr to UIntPtr {
  @:op(A+B) inline public function addOffset(offset:Int):AnyPtr {
    return this + offset;
  }

#if (!bake_externs && cpp && !UHX_NO_UOBJECT)
  public function getUObject(at:Int):UObject {
    var ptr = this + at;
    return UObject.wrap(ptr);
  }

  public function getStruct(at:Int):Struct {
    return cast VariantPtr.fromUIntPtr(this + at + 1);
  }

  public static function fromUObject(obj:UObject):AnyPtr {
    return @:privateAccess obj.wrapped;
  }

  public static function fromStruct(obj:Struct):AnyPtr {
    var variantPtr:VariantPtr = cast obj;
    if (variantPtr.isObject()) {
      return (variantPtr.getDynamic() : Wrapper).getPointer();
    } else {
      return variantPtr.raw - 1;
    }
  }

  public static function fromNull():AnyPtr {
    return 0;
  }
#end
}
