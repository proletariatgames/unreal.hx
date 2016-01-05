package unreal.helpers;
import cpp.RawPointer;
import cpp.Function;

@:native('unreal.helpers.ClassMap')
@:include("ClassMap.h") extern class ClassMap {
  /**
   * Adds a wrapper so that given `inUClass`, the function `wrapper` will be called to wrap it
   **/
  static function addWrapper(inUClass:RawPointer<cpp.Void>, inWrapper:Function<RawPointer<cpp.Void>->RawPointer<cpp.Void>, cpp.abi.Abi>):Void;

  /**
   * Given `inUObject`, find the best wrapper and return the Haxe wrapper to it
   **/
  static function wrap(inUObject:RawPointer<cpp.Void>):RawPointer<cpp.Void>;
}
