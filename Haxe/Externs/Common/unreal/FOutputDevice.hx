package unreal;

@:glueCppIncludes("Misc/OutputDevice.h")
@:noCopy
@:noEquals
@:uextern extern class FOutputDevice {
  /**
    Global logger, in cpp this is a macro for FOutputDeviceRedirector::Get()
   **/
  @:global
  static var GLog(default, never) : PPtr<FOutputDevice>;

  @:global
  static var GWarn(default, never) : PPtr<FOutputDevice>;

  @:global
  static var GError(default, never) : PPtr<FOutputDevice>;

  @:ublocking function Flush():Void;

  /**
    Closes output device and cleans up. This can't happen in the destructor
    as we might have to call "delete" which cannot be done for static/ global
    objects.
   **/
  function TearDown():Void;

  @:final function SetSuppressEventTag(inSuppressEventTag:Bool):Void;
  @:final function SetAutoEmitLineTerminator(inAutoEmitLineTerminator:Bool):Void;
  @:thisConst function CanBeUsedOnAnyThread():Bool;

  @:ublocking function Log(str:TCharStar):Void;
  @:ublocking @:uname('Log') function LogWithVerbosity(verbosity:ELogVerbosity, str:TCharStar):Void;
  @:ublocking @:uname('Log') function LogWithCategory(category:Const<FName>, verbosity:ELogVerbosity, str:TCharStar):Void;

  @:ublocking function Serialize(data:Const<unreal.TCharStar>, verbosity:ELogVerbosity, category:Const<PRef<FName>>):Void;
  @:ublocking @:uname("Serialize") function SerializeWithTime(
    data:Const<unreal.TCharStar>, verbosity:ELogVerbosity, category:Const<PRef<FName>>, time:Const<unreal.Float64>):Void;
}
