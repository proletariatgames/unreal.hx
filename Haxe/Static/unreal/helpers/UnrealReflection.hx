package unreal.helpers;

#if !UHX_NO_UOBJECT
@:include("uhx/UnrealReflection.h")
extern class UnrealReflection {
  public static function wrapProperty(inProp:UIntPtr, pointerIfAny:UIntPtr):VariantPtr;
  public static function getHaxeGcRefOffset():Int;
  public static function setupClassConstructor(cls:UIntPtr, parent:UIntPtr, parentHxGenerated:Bool):UIntPtr;
}
#end
