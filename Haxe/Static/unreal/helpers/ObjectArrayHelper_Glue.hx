package unreal.helpers;

@:unrealGlue extern class ObjectArrayHelper_Glue {
  public static function indexToObject(idx:Int):unreal.UIntPtr;
  public static function indexToSerial(idx:Int):Int;
  public static function indexToSerialPendingKill(idx:Int):Int;
  public static function objectToIndex(obj:unreal.UIntPtr):Int;
  public static function allocateSerialNumber(idx:Int):Int;
  public static function isValid(index:Int, serial:Int, evenIfPendingKill:Bool):Bool;
  public static function setObjectFlags(idx:Int, flags:Int):Bool;
  public static function clearObjectFlags(idx:Int, flags:Int):Bool;
  public static function getObjectFlags(idx:Int):Int;
}
