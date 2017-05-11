package uhx.internal;

@:unrealGlue extern class Log_Glue {
  public static function trace(str:unreal.UIntPtr):Void;
  public static function warning(str:unreal.UIntPtr):Void;
  public static function error(str:unreal.UIntPtr):Void;
  public static function fatal(str:unreal.UIntPtr):Void;
}
