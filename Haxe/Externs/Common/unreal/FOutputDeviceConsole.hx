package unreal;

import unreal.FOutputDevice;

@:glueCppIncludes("Misc/OutputDeviceConsole.h", "CoreGlobals.h")
@:noCopy
@:noEquals
@:uextern extern class FOutputDeviceConsole extends FOutputDevice {
  /**
    Global console logger singleton
    Note: FWindowsPlatformOutputDevices::GetLogConsole() will make a new instance, so don't call it.
   **/
  @:global static var GLogConsole(default, never) : PPtr<FOutputDeviceConsole>;

  /**
    Shows or hides the console window.
   **/
  function Show(showWindow:Bool):Void;

  /**
    Returns whether console is currently shown or not.
   **/
  function IsShown():Bool;

  /**
    Returns whether the application is already attached to a console window.
   **/
  function IsAttached():Bool;

  /**
    Sets the INI file name to write console settings to.
   **/
  function SetIniFilename(inFilename:Const<TCharStar>):Void;
}
