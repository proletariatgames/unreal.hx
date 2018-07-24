package unreal;

@:include("VariantPtr.h") @:native("unreal.VariantPtr")
extern class VariantPtr {
  /**
    Creates a `VariantPtr` from a Haxe object
   **/
  public static function fromDynamic(obj:Dynamic):VariantPtr;

  /**
    Creates a `VariantPtr` from an external `UIntPtr`
   **/
  public static function fromExternalPointer(uintPtr:UIntPtr):VariantPtr;

#if cpp
  public static function fromExternalHxcppPointer<T>(ptr:cpp.Pointer<T>):VariantPtr;
#end

  /**
    Gets its underlying Dynamic object. If it doesn't represent an object, `null` will be returned
   **/
  public function getDynamic():Null<Dynamic>;

  /**
    Returns whether `this` represents an object or an `IntPtr` value
   **/
  public function isObject():Bool;

  public function isExternalPointer():Bool;

  public function getExternalPointerUnchecked():UIntPtr;

  public function getGcPointerUnchecked():UIntPtr;

  public function getExternalPointer():UIntPtr;

  /**
   * If it's an external pointer, returns the pointer itself
   * Otherwise, the Dynamic object is assyned to be an unreal.Wrapper type,
   * and `getPointer()` is called, so the underlying native pointer is returned
   **/
  public function getUnderlyingPointer():UIntPtr;

  public function getUIntPtrRepresentation():UIntPtr;
}
