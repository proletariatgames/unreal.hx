package unreal;

import unreal.*;
import unreal.onlinesubsystem.*;

@:glueCppIncludes("OnlineKeyValuePair.h")
@:uname("FVariantData")
@:noEquals
@:uextern extern class FVariantData
{
  @:uname('.ctor') static function create(InVal:FString):FVariantData;
}

typedef FPresenceKey = FString;

@:glueCppIncludes("OnlinePresenceInterface.h")
typedef FPresenceProperties = FOnlineKeyValuePairs<FPresenceKey, FVariantData>;


@:glueCppIncludes("OnlinePresenceInterface.h")

@:uname("EOnlinePresenceState.Type")
@:uextern @:uenum extern enum EOnlinePresenceStateType {
  Online;
  Offline;
  Away;
  ExtendedAway;
  DoNotDisturb;
  Chat;
}

@:glueCppIncludes("OnlinePresenceInterface.h")
@:uname("FOnlineUserPresenceStatus")
@:uextern extern class FOnlineUserPresenceStatus {
  @:uname('.ctor') static function create():FOnlineUserPresenceStatus;

	public var StatusStr:FString;
	public var State:EOnlinePresenceStateType;
  public var Properties:FPresenceProperties;
}
