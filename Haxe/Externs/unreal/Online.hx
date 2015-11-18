package unreal;

@:glueCppIncludes("Online.h")
@:uextern @:noClass @:noCopy @:noEquals extern class Online
{
  @:global public static var GameSessionName(default, never) : Const<FName>;
  @:global public static var PartySessionName(default, never) : Const<FName>;

  @:global public static var GamePort(default, never) : Const<FName>;
  @:global public static var BeaconPort(default, never) : Const<FName>;

  public static function GetSessionInterface() : TThreadSafeSharedPtr<IOnlineSession>;
}
