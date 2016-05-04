package unreal;

@:forward
abstract AnyPtr(VariantPtr) from VariantPtr to VariantPtr {
  @:op(A+B) public function addOffset(offset:Int):AnyPtr {
    var ptr = this.isObject() ? (this.getDynamic() : Wrapper ).getPointer() : cast this.getIntPtr();
    return VariantPtr.fromUIntPtr( ptr + offset );
  }

#if (!bake_externs && cpp)
  public function getUObject(at:Int):UObject {
    var ptr:cpp.Pointer<cpp.UInt8>;
    if (this.isObject()) {
      var wrap:Wrapper = this.getDynamic(),
          myPtr:cpp.RawPointer<cpp.UInt8> = untyped __cpp__('(unsigned char *) {0}', wrap.getPointer());
      ptr = cpp.Pointer.fromRaw(myPtr);
    } else {
      ptr = cpp.Pointer.fromRaw(this.toPointer()).reinterpret();
    }
    if (at != 0) {
      ptr = ptr.add(at);
    }

    return UObject.wrap( untyped __cpp__('( (unreal::UIntPtr) (void *) {0} )', ptr.rawCast()) );
  }

  public static function fromUObject(obj:UObject):AnyPtr {
    return VariantPtr.fromPointer( untyped __cpp__('(void *) {0}', @:privateAccess obj.wrapped) );
  }

  public static function fromStruct(obj:Struct):AnyPtr {
    return (obj : VariantPtr);
  }

  public static function fromNull():AnyPtr {
    return null;
  }
#end
}
