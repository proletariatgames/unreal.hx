package uhx.ue;
import cpp.Function;
import unreal.UIntPtr;

@:native('uhx.ue.ClassMap')
@:include("uhx/ue/ClassMap.h") extern class ClassMap {
  /**
   * Adds a wrapper so that given `inUClass`, the function `wrapper` will be called to wrap it
   **/
  static function addWrapper(inUClass:UIntPtr, inWrapper:Function<UIntPtr->UIntPtr, cpp.abi.Abi>):Void;

  /**
   * Given `inUObject`, find the best wrapper and return the Haxe wrapper to it
   **/
  static function wrap(inUObject:UIntPtr):UIntPtr;

  static function runInits():Void;

  static function addCppiaExternWrapper(inUClass:cpp.ConstCharStar, inHxClass:cpp.ConstCharStar):Void;
  static function addCppiaCustomCtor(inUClass:cpp.ConstCharStar, inHxClass:cpp.ConstCharStar):Void;
  static function addCustomCtor(inUClass:UIntPtr, inWrapper:Function<UIntPtr->UIntPtr, cpp.abi.Abi>):Void;
}
