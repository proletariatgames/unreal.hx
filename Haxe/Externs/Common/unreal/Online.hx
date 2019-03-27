package unreal;

@:glueCppIncludes("Online.h")
@:uextern @:noClass @:noCopy @:noEquals extern class Online
{
  public static function GetSessionInterface() : TThreadSafeSharedPtr<IOnlineSession>;
}
