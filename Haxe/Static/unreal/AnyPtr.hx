package unreal;

@:forward
abstract AnyPtr(VariantPtr) from VariantPtr to VariantPtr {
  @:op(A+B) public function addOffset(offset:Int):AnyPtr {
    var ptr = this.isObject() ? (this.getDynamic() : Wrapper ).getPointer() : cast this.getIntPtr();
    return VariantPtr.fromUIntPtr( ptr + offset );
  }

#if (!bake_externs && cpp)
  public function getUObject(at:Int):UObject {
    var ptr:cpp.Pointer<cpp.UInt8> = this.isObject() ?
      cpp.Pointer.fromRaw(cast (this.getDynamic() : Wrapper).getPointer()) :
      cpp.Pointer.fromRaw(this.toPointer()).reinterpret();
    if (at != 0) {
      ptr = ptr.add(at);
    }

    return UObject.wrap(( cast ptr.rawCast() : unreal.UIntPtr ));
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
