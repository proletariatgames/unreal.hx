package unreal.helpers;

#if !UHX_NO_UOBJECT
@:include("uhx/UnrealReflection.h")
extern class UnrealReflection {
  public static function wrapProperty(inProp:UIntPtr, pointerIfAny:UIntPtr):VariantPtr;
}
#end
