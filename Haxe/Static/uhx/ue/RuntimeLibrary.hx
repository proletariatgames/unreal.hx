package uhx.ue;
import unreal.*;

@:include("uhx/ue/RuntimeLibrary.h")
extern class RuntimeLibrary {
  public static function getTlsObj():UIntPtr;
  public static function allocTlsSlot():Int;
#if !UHX_NO_UOBJECT
  public static function wrapProperty(inProp:UIntPtr, pointerIfAny:UIntPtr):VariantPtr;
  public static function getHaxeGcRefOffset():Int;
  public static function getGcRefSize():Int;
  public static function setSuperClassConstructor(cls:UIntPtr):Void;
  public static function setupClassConstructor(dynamicClass:UIntPtr):Void;
  public static function createDynamicWrapperFromStruct(inStruct:UIntPtr):VariantPtr;
  public static function setReflectionDebugMode(value:Bool):Void;
  public static function getReflectionDebugMode():Bool;
#end
  public static function dummyCall():Void;

  @:extern inline public static function alloca(size:Int):UIntPtr {
    dummyCall();
    return untyped __cpp__('HX_ALLOCA({0})', size);
  }

  @:extern inline public static function allocaZeroed(size:Int):UIntPtr {
    dummyCall();
    return untyped __cpp__('HX_ALLOCA_ZEROED({0})', size);
  }
}