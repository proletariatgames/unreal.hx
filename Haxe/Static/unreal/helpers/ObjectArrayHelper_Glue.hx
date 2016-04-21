package unreal.helpers;

@:unrealGlue extern class ObjectArrayHelper_Glue {
  public static function indexToObject(idx:Int):cpp.RawPointer<cpp.Void>;
  public static function indexToSerial(idx:Int):Int;
  public static function objectToIndex(obj:cpp.RawPointer<cpp.Void>):Int;
  public static function allocateSerialNumber(idx:Int):Int;
}
