package unreal;

import unreal.UObject;
import unreal.Wrapper;

@:access(unreal.Wrapper)
@:access(unreal.UObject.wrapped)
class CoreAPI {

  public static function equals(a:Dynamic, b:Dynamic) : Bool {
    if ((a == null) && (b == null)) {
      return true;
    } else if (a == null || b == null) {
      return false;
    } else if (Std.is(a, Wrapper) && Std.is(b, Wrapper)) {
      var wrapperA:Wrapper = cast a;
      var wrapperB:Wrapper = cast b;
      if (wrapperA.wrapped.ptr.getPointer() == wrapperB.wrapped.ptr.getPointer())
        return true;
      if (Type.getClass(wrapperA) == Type.getClass(wrapperB))
        return wrapperA._equals(wrapperB);
      return false;
    } else if (Std.is(a, unreal.UObject) && Std.is(b, UObject)) {
      var uobjectA:UObject = cast a;
      var ubojectB:UObject = cast b;
      return uobjectA.wrapped == ubojectB.wrapped;
    }
    return a == b;
  }

  inline public static function copy<T : Wrapper>(type:T):PHaxeCreated<T> {
    return cast type._copy();
  }

  inline public static function copyStruct<T : Wrapper>(type:T):T {
    return cast type._copyStruct();
  }
}
