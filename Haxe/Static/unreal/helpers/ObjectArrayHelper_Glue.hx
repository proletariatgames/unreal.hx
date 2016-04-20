package unreal.helpers;

@:unrealGlue extern class ObjectArrayHelper_Glue {
  public static function indexToObject(idx:Int):cpp.RawPointer<cpp.Void>;
  public static function indexToSerial(idx:Int):Int;
}
