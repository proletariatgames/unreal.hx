package unreal;

@:forward
abstract AnyPtr(UIntPtr) from UIntPtr to UIntPtr {
  @:op(A+B) inline public function addOffset(offset:Int):AnyPtr {
    return this + offset;
  }

  @:op(A-B) inline public function remOffset(offset:Int):AnyPtr {
    return this - offset;
  }

  inline public function asUIntPtr() {
    return this;
  }

#if (!bake_externs && cpp && !UHX_NO_UOBJECT)
  public function getUObject(at:Int):UObject {
    var ptr = this + at;
    return UObject.wrap(ptr);
  }

  public function getInt(at:Int):Int {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int> = cpp.Pointer.fromRaw(untyped __cpp__("(int*){0}", curThis));
    return ptr.value;
  }

  public function getInt8(at:Int):Int {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int8> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Int8*){0}", curThis));
    return ptr.value;
  }

  public function getInt16(at:Int):Int {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int16> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Int16*){0}", curThis));
    return ptr.value;
  }

  public function getInt64(at:Int):Int64 {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int64> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Int64*){0}", curThis));
    return ptr.value;
  }

  public function getUInt(at:Int):UInt {
    var curThis = this + at;
    var ptr:cpp.Pointer<UInt> = cpp.Pointer.fromRaw(untyped __cpp__("(int*){0}", curThis));
    return ptr.value;
  }

  public function getUInt8(at:Int):Int {
    var curThis = this + at;
    var ptr:cpp.Pointer<UInt8> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::UInt8*){0}", curThis));
    return ptr.value;
  }

  public function getUInt16(at:Int):Int {
    var curThis = this + at;
    var ptr:cpp.Pointer<UInt16> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::UInt16*){0}", curThis));
    return ptr.value;
  }

  public function getUInt64(at:Int):UInt64 {
    var curThis = this + at;
    var ptr:cpp.Pointer<UInt64> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::UInt64*){0}", curThis));
    return ptr.value;
  }

  public function getPointer(at:Int):AnyPtr {
    var curThis = this + at;
    var ptr:cpp.Pointer<UIntPtr> = cpp.Pointer.fromRaw(untyped __cpp__("(unreal::UIntPtr*){0}", curThis));
    return ptr.value;
  }

  public function getFloat32(at:Int):Float32 {
    var curThis = this + at;
    var ptr:cpp.Pointer<Float32> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Float32*){0}", curThis));
    return ptr.value;
  }

  public function getFloat(at:Int):Float {
    var curThis = this + at;
    var ptr:cpp.Pointer<Float> = cpp.Pointer.fromRaw(untyped __cpp__("(Float*){0}", curThis));
    return ptr.value;
  }

  public function getBool(at:Int):Bool {
    var curThis = this + at;
    var ptr:cpp.Pointer<Bool> = cpp.Pointer.fromRaw(untyped __cpp__("(bool*){0}", curThis));
    return ptr.value;
  }

  public function setUObject(at:Int, val:UObject):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<UIntPtr> = cpp.Pointer.fromRaw(untyped __cpp__("(unreal::UIntPtr*){0}", curThis));
    if (val == null) {
      ptr.ref = 0;
    } else {
      ptr.ref = @:privateAccess val.wrapped;
    }
  }

  public function setInt(at:Int, val:Int):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int> = cpp.Pointer.fromRaw(untyped __cpp__("(int*){0}", curThis));
    ptr.ref = val;
  }

  public function setInt8(at:Int, val:Int):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int8> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Int8*){0}", curThis));
    ptr.ref = val;
  }

  public function setInt16(at:Int, val:Int):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int16> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Int16*){0}", curThis));
    ptr.ref = val;
  }

  public function setInt64(at:Int, val:Int64):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<Int64> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Int64*){0}", curThis));
    ptr.ref = val;
  }

  public function setPointer(at:Int, val:AnyPtr):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<UIntPtr> = cpp.Pointer.fromRaw(untyped __cpp__("(unreal::UIntPtr*){0}", curThis));
    ptr.ref = val;
  }

  public function setFloat32(at:Int, val:Float32):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<Float32> = cpp.Pointer.fromRaw(untyped __cpp__("(cpp::Float32*){0}", curThis));
    ptr.ref = val;
  }

  public function setFloat(at:Int, val:Float):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<Float> = cpp.Pointer.fromRaw(untyped __cpp__("(Float*){0}", curThis));
    ptr.ref = val;
  }

  public function setBool(at:Int, val:Bool):Void {
    var curThis = this + at;
    var ptr:cpp.Pointer<Bool> = cpp.Pointer.fromRaw(untyped __cpp__("(bool*){0}", curThis));
    ptr.ref = val;
  }

  public function getStruct(at:Int):Struct {
    return cast VariantPtr.fromExternalPointer(this + at);
  }

  public static function fromUObject(obj:UObject):AnyPtr {
    return @:privateAccess obj.wrapped;
  }

  public static function fromStruct(obj:Struct):AnyPtr {
    var variantPtr:VariantPtr = cast obj;
    return variantPtr.getUnderlyingPointer();
  }

  public static function fromNull():AnyPtr {
    return 0;
  }
#end
}
