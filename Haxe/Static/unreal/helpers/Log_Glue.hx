package unreal.helpers;

extern class Log_Glue {
  public static function trace(str:cpp.RawPointer<cpp.Void>):Void;
  public static function warning(str:cpp.RawPointer<cpp.Void>):Void;
  public static function error(str:cpp.RawPointer<cpp.Void>):Void;
  public static function fatal(str:cpp.RawPointer<cpp.Void>):Void;
}
