package unreal.onlinesubsystem;

import unreal.*;
import unreal.onlinesubsystem.FOnlineError;

@:glueCppIncludes("Online.h") @:umodule("OnlineSubsystem")

typedef FOnAddRecentPlayersComplete = Delegate<FOnAddRecentPlayersComplete, PRef<Const<FUniqueNetId>>->PRef<Const<FOnlineError>>->Void>;

/**
 * Single purchased offer offer
 */
@:glueCppIncludes("OnlineFriendsInterface.h") @:umodule("OnlineSubsystem")
@:uname("FReportPlayedWithUser")
@:noCopy
@:uextern extern class FReportPlayedWithUser
{
	public var PresenceStr:FString;
	public var UserId:TSharedRef<Const<FUniqueNetId>>;
}

@:uname("IOnlineFriends")
@:glueCppIncludes("Online.h")
@:noCopy
@:uextern extern class IOnlineFriends {

	public function AddRecentPlayers(UserId : PRef<Const<FUniqueNetId>>, InRecentPlayers : TArray<FReportPlayedWithUser>, ListName : FString, InCompletionDelegate : FOnAddRecentPlayersComplete) : Void;
	public function DumpRecentPlayers() : Void;
}
