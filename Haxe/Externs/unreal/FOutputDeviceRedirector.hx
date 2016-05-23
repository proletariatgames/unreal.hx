package unreal;

import unreal.FOutputDevice;

@:glueCppIncludes("HAL/OutputDevices.h")
@:noCopy
@:noEquals
@:uextern extern class FOutputDeviceRedirector extends FOutputDevice {
  // Redirector singleton; in cpp GLog is #define'd to call this
  public static function Get():PExternal<FOutputDeviceRedirector>;

  // Manage the list of output devices
  function AddOutputDevice(outputDevice:PExternal<FOutputDevice>):Void;
  function RemoveOutputDevice(outputDevice:PExternal<FOutputDevice>):Void;
  function IsRedirectingTo(outputDevice:PExternal<FOutputDevice>):Bool;
}
