package unreal;

@:include("VariantPtr.h") @:native("unreal.VariantPtr")
extern class VariantPtr {
  /**
    Creates a `VariantPtr` from a Haxe object
   **/
  public static function fromDynamic(obj:Dynamic):VariantPtr;

  /**
    Creates a `VariantPtr` from an `IntPtr`. Please note that the most significant bit of the IntPtr will be lost
   **/
  public static function fromIntPtr(intPtr:IntPtr):VariantPtr;

  /**
    Creates a `VariantPtr` from an `IntPtr`. Please note that the most significant bit of the UIntPtr will be lost
   **/
  public static function fromUIntPtr(uintPtr:UIntPtr):VariantPtr;


#if cpp
  public static function fromPointer<T>(ptr:cpp.Pointer<T>):VariantPtr;

  public static function fromRawPtr<T>(ptr:cpp.RawPointer<T>):VariantPtr;
#end

  /**
    Gets its underlying Dynamic object. If it doesn't represent an object, `null` will be returned
   **/
  public function getDynamic():Null<Dynamic>;

  /**
    Gets its underlying IntPtr value. This is the same as doing `rawValue >> 1`
   **/
  public function getIntPtr():IntPtr;

  /**
    Returns whether `this` represents an object or an `IntPtr` value
   **/
  public function isObject():Bool;

#if cpp
  public function toPointer():cpp.RawPointer<cpp.Void>;
#end
}
