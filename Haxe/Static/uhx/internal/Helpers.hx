package uhx.internal;
import unreal.*;

class Helpers {
  public static var pointerSize(default, null):Int = untyped __cpp__("(int) (sizeof (void *))");

  public static function getWrapperPointer(vptr : VariantPtr) : UIntPtr {
    if (vptr.isObject()) {
      var wrapper:Wrapper = vptr.getDynamic();
      return wrapper.getPointer();
    } else {
      return vptr.getUIntPtr() - 1;
    }
  }

  public static function createPodWrapper(size:Int) {
    return unreal.Wrapper.InlinePodWrapper.create(size, 0);
  }
}