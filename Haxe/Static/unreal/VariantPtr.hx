package unreal;

@:include("VariantPtr.h") @:native("unreal.VariantPtr")
extern class VariantPtr {
  var raw(default, null):UIntPtr;
  /**
    Creates a `VariantPtr` from a Haxe object
   **/
  public static function fromDynamic(obj:Dynamic):VariantPtr;

  /**
    Creates a `VariantPtr` from an `IntPtr`.
   **/
  public static function fromIntPtr(intPtr:IntPtr):VariantPtr;

  /**
    Creates a `VariantPtr` from an `IntPtr`. This directly sets `uintPtr` value as the raw value of VariantPtr.
    If you want to set an external pointer with this, use `fromUIntPtrExternalPointer` instead
   **/
  public static function fromUIntPtr(uintPtr:UIntPtr):VariantPtr;

  /**
    Creates a `VariantPtr` from an `IntPtr`, considering it an external pointer (like `fromPointer` / `fromRawPtr` )
    This differs from `fromUIntPtr` as it will set the bit as if the pointer references external code
  **/
  public static function fromUIntPtrExternalPointer(uintPtr:UIntPtr):VariantPtr;
#if cpp
  public static function fromPointer<T>(ptr:cpp.Pointer<T>):VariantPtr;

  public static function fromRawPtr<T>(ptr:cpp.RawPointer<T>):VariantPtr;
#end

  /**
    Gets its underlying Dynamic object. If it doesn't represent an object, `null` will be returned
   **/
  public function getDynamic():Null<Dynamic>;

  /**
    Gets its underlying IntPtr value
   **/
  public function getIntPtr():IntPtr;

  /**
    Gets its underlying UIntPtr value
   **/
  public function getUIntPtr():UIntPtr;

  /**
    Returns whether `this` represents an object or an `IntPtr` value
   **/
  public function isObject():Bool;

#if cpp
  public function toPointer():cpp.RawPointer<cpp.Void>;
#end
}
