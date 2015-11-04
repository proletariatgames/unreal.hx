package unreal;

import unreal.UObject;
import unreal.Wrapper;

class CoreAPI {

  @:access(unreal.Wrapper.wrapped)
  @:access(unreal.UObject.wrapped)
  public static function pointerEquals(a:Dynamic, b:Dynamic) : Bool {
    if ((a == null) && (b == null)) {
      return true;
    } else if (a == null || b == null) {
      return false;
    } else if (Std.is(a, Wrapper) && Std.is(b, Wrapper)) {
      var wrapperA:Wrapper = cast a;
      var wrapperB:Wrapper = cast b;
      return wrapperA.wrapped.ptr.getPointer() == wrapperB.wrapped.ptr.getPointer();
    } else if (Std.is(a, unreal.UObject) && Std.is(b, UObject)) {
      var uobjectA:UObject = cast a;
      var ubojectB:UObject = cast b;
      return uobjectA.wrapped == ubojectB.wrapped;
    }
    return a == b;
  }

  @:access(unreal.Wrapper)
  @:access(unreal.UObject.wrapped)
  public static function equals(a:Dynamic, b:Dynamic) : Bool {
    if ((a == null) && (b == null)) {
      return true;
    } else if (a == null || b == null) {
      return false;
    } else if (Std.is(a, Wrapper) && Std.is(b, Wrapper)) {
      var wrapperA:Wrapper = cast a;
      var wrapperB:Wrapper = cast b;
      return wrapperA.wrapped.ptr.getPointer() == wrapperB.wrapped.ptr.getPointer() ||
             wrapperA._equals(wrapperB);
    } else if (Std.is(a, unreal.UObject) && Std.is(b, UObject)) {
      var uobjectA:UObject = cast a;
      var ubojectB:UObject = cast b;
      return uobjectA.wrapped == ubojectB.wrapped;
    }
    return a == b;
  }
}