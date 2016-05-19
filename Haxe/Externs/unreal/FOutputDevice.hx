package unreal;

@:glueCppIncludes("Misc/OutputDevice.h")
@:noCopy
@:noEquals
@:uextern extern class FOutputDevice {

  @:global
  static var GLog(default, never) : PExternal<FOutputDevice>;

  function Flush():Void;

  /**
    Closes output device and cleans up. This can't happen in the destructor
    as we might have to call "delete" which cannot be done for static/ global
    objects.
   **/
  function TearDown():Void;

  @:final function SetSuppressEventTag(inSuppressEventTag:Bool):Void;
  @:final function SetAutoEmitLineTerminator(inAutoEmitLineTerminator:Bool):Void;
  @:thisConst function CanBeUsedOnAnyThread():Bool;

  function Log(str:TCharStar):Void;
  @:uname('Log') function LogWithVerbosity(verbosity:ELogVerbosity, str:TCharStar):Void;
  @:uname('Log') function LogWithCategory(category:Const<FName>, verbosity:ELogVerbosity, str:TCharStar):Void;

  function Serialize(data:Const<unreal.TCharStar>, verbosity:ELogVerbosity, category:Const<PRef<FName>>):Void;
  @:uname("Serialize") function SerializeWithTime(
    data:Const<unreal.TCharStar>, verbosity:ELogVerbosity, category:Const<PRef<FName>>, time:Const<unreal.Float64>):Void;
}
