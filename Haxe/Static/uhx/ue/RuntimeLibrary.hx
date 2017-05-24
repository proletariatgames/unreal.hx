package uhx.ue;
import unreal.*;

#if !UHX_NO_UOBJECT
@:include("uhx/ue/RuntimeLibrary.h")
extern class RuntimeLibrary {
  public static function wrapProperty(inProp:UIntPtr, pointerIfAny:UIntPtr):VariantPtr;
  public static function getHaxeGcRefOffset():Int;
  public static function setupClassConstructor(cls:UIntPtr, parent:UIntPtr, parentHxGenerated:Bool):UIntPtr;
  public static function dummyCall():Void;

  @:extern inline public static function alloca(size:Int):UIntPtr {
    dummyCall();
    return untyped __cpp__('HX_ALLOCA({0})', size);
  }
}
#end
