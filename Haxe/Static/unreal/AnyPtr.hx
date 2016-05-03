package unreal;

@:forward
abstract AnyPtr(VariantPtr) from VariantPtr to VariantPtr {
  @:op(A+B) public function addOffset(offset:Int):AnyPtr {
    var ptr = this.isObject() ? (this.getDynamic() : Wrapper ).getPointer() : cast this.getIntPtr();
    return VariantPtr.fromUIntPtr( ptr + offset );
  }

#if !bake_externs
  public function getUObject(at:Int):UObject {
    return UObject.wrap(at == 0 ? this : this.add(at));
  }

  public static function fromUObject(obj:UObject):AnyPtr {
    return VariantPtr.fromPointer( cast @:privateAccess obj.wrapped );
  }

  public static function fromStruct(obj:Struct):AnyPtr {
    return (obj : VariantPtr);
  }

  public static function fromNull():AnyPtr {
    return null;
  }
#end
}
