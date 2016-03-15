package unreal;

@:glueCppIncludes("HAL/OutputDevices.h")
@:noCopy
@:noEquals
@:uextern extern class FOutputDeviceRedirector extends FOutputDevice {
  public static function Get():PExternal<FOutputDeviceRedirector>;
}
