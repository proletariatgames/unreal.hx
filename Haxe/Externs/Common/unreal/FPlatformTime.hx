package unreal;

@:glueCppIncludes("HAL/PlatformTime.h")
@:uextern extern class FPlatformTime {
  public static function Seconds():Float64;
  public static function Cycles():UInt32;
}
