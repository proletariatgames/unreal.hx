package unreal;

//
// Reference from C++ for Settings FNames
//
// /** Setting describing the name of the current map (value is FString) */
// #define SETTING_MAPNAME FName(TEXT("MAPNAME"))
// /** Setting describing the number of bots in the session (value is int32) */
// #define SETTING_NUMBOTS FName(TEXT("NUMBOTS"))
// /** Setting describing the game mode of the session (value is FString) */
// #define SETTING_GAMEMODE FName(TEXT("GAMEMODE"))
// /** Setting describing the beacon host port (value is int32) */
// #define SETTING_BEACONPORT FName(TEXT("BEACONPORT"))
// /** Server responds to Qos beacon requests (value is int32) */
// #define SETTING_QOS FName(TEXT("QOS"))
// /** Setting describing the region of the world you are in (value is FString) */
// #define SETTING_REGION FName(TEXT("REGION"))
// /** Setting describing the unique id of a datacenter (value is FString) */
// #define SETTING_DCID FName(TEXT("DCID"))
// /** Number of players needed to fill out this session (value is int32) */
// #define SETTING_NEEDS FName(TEXT("NEEDS"))
// /** Second key for "needs" because can't set same value with two criteria (value is int32) */
// #define SETTING_NEEDSSORT FName(TEXT("NEEDSSORT"))

// /** 8 user defined integer params to be used when filtering searches for sessions */
// #define SETTING_CUSTOMSEARCHINT1 FName(TEXT("CUSTOMSEARCHINT1"))
// #define SETTING_CUSTOMSEARCHINT2 FName(TEXT("CUSTOMSEARCHINT2"))
// #define SETTING_CUSTOMSEARCHINT3 FName(TEXT("CUSTOMSEARCHINT3"))
// #define SETTING_CUSTOMSEARCHINT4 FName(TEXT("CUSTOMSEARCHINT4"))
// #define SETTING_CUSTOMSEARCHINT5 FName(TEXT("CUSTOMSEARCHINT5"))
// #define SETTING_CUSTOMSEARCHINT6 FName(TEXT("CUSTOMSEARCHINT6"))
// #define SETTING_CUSTOMSEARCHINT7 FName(TEXT("CUSTOMSEARCHINT7"))
// #define SETTING_CUSTOMSEARCHINT8 FName(TEXT("CUSTOMSEARCHINT8"))

@:glueCppIncludes("OnlineSessionSettings.h")
@:uextern extern class FOnlineSessionSettings {
	/** The number of publicly available connections advertised */
  var NumPublicConnections:Int32;
	/** The number of connections that are private (invite/password) only */
  var NumPrivateConnections:Int32;
	/** Whether this match is publicly advertised on the online service */
  var bShouldAdvertise:Bool;
	/** Whether joining in progress is allowed or not */
  var bAllowJoinInProgress:Bool;
	/** This game will be lan only and not be visible to external players */
  var bIsLANMatch:Bool;
	/** Whether the server is dedicated or player hosted */
  var bIsDedicated:Bool;
	/** Whether the match should gather stats or not */
  var bUsesStats:Bool;
	/** Whether the match allows invitations for this session or not */
  var bAllowInvites:Bool;
	/** Whether to display user presence information or not */
  var bUsesPresence:Bool;
	/** Whether joining via player presence is allowed or not */
  var bAllowJoinViaPresence:Bool;
	/** Whether joining via player presence is allowed for friends only or not */
  var bAllowJoinViaPresenceFriendsOnly:Bool;
	/** Whether the server employs anti-cheat (punkbuster, vac, etc) */
  var bAntiCheatProtected:Bool;
	/** Used to keep different builds from seeing each other during searches */
  var BuildUniqueId:Int32;
  // var Settings:FSessionSettings;

  @:uname(".ctor")
  public static function create() : FOnlineSessionSettings;
  @:uname("new")
  public static function createNew() : POwnedPtr<FOnlineSessionSettings>;

  	/**
	 *	Sets a key value pair combination that defines a session setting
	 *
	 * @param Key key for the setting
	 * @param Value value of the setting
	 * @param InType type of online advertisement
	 */
  @:uname("Set")
	public function SetString(Key:FName,
    Value:Const<PRef<FString>>,
    InType:unreal.onlinesubsystem.EOnlineDataAdvertisementType) : Void;
}
