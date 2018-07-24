package uhx.expose;
import unreal.UIntPtr;

/**
  This is just like `HxcppRuntime`, but provides a minimal API for the VariantPtr implementation
**/
@:uexpose @:keep class BaseRuntime
{
  @:void public static function throwString(str:cpp.ConstCharStar) : Void {
    throw str.toString();
  }

  public static function wrapperObjectToPointer(wrapperPtr:UIntPtr):UIntPtr {
    var wrapper:unreal.Wrapper = uhx.internal.HaxeHelpers.pointerToDynamic(wrapperPtr);
    return wrapper.getPointer();
  }

  @:void public static function throwBadPointer(ptr:UIntPtr) : Void {
    throw 'The pointer "$ptr" is invalid';
  }

  public static function boxPointer(ptr:UIntPtr):UIntPtr
  {
    var vptr = unreal.VariantPtr.fromExternalPointer(ptr);
    var ret:Dynamic = vptr;
    return uhx.internal.HaxeHelpers.dynamicToPointer(ret);
  }

  public static function getPointerHandle(ptr:UIntPtr):UIntPtr
  {
    var dyn:Dynamic = uhx.internal.HaxeHelpers.pointerToDynamic(ptr);
    var ptr:UIntPtr = untyped __cpp__("(unreal::UIntPtr) ({0}->__GetHandle())", dyn);
    return ptr;
  }
}