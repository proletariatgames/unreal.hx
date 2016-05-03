package unreal;

@:glueCppIncludes("OnlineSessionSettings.h")
@:uextern extern class FOnlineSessionSettings {
  var NumPublicConnections:Int32;
  var NumPrivateConnections:Int32;
  var bShouldAdvertise:Bool;
  var bAllowJoinInProgress:Bool;
  var bIsLANMatch:Bool;
  var bIsDedicated:Bool;
  var bUsesStats:Bool;
  var bAllowInvites:Bool;
  var bUsesPresence:Bool;
  var bAllowJoinViaPresence:Bool;
  var bAllowJoinViaPresenceFriendsOnly:Bool;
  var bAntiCheatProtected:Bool;
  var BuildUniqueId:Int32;
  // var Settings:FSessionSettings;

  @:uname(".ctor")
  public static function create() : FOnlineSessionSettings;
  @:uname("new")
  public static function createNew() : POwnedPtr<FOnlineSessionSettings>;
}
