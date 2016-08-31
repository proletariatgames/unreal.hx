package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineLeaderboardInterface.h") @:umodule("OnlineSubsystem")

@:uname("IOnlineLeaderboards")
@:noCopy
@:uextern extern class IOnlineLeaderboards {
  public function WriteLeaderboards( sessionName : unreal.Const<unreal.FName>, playerId : unreal.PRef<unreal.Const<FUniqueNetId>>, writeObject : unreal.PRef<FOnlineLeaderboardWrite>) : Bool;
  public function FlushLeaderboards( sessionName : unreal.Const<unreal.FName>) : Void;
}
