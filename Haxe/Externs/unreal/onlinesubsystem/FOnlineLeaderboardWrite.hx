package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineStats.h")
@:umodule("OnlineSubsystem")
@:uname("FOnlineLeaderboardWrite")
@:noCopy
@:uextern extern class FOnlineLeaderboardWrite extends FOnlineStats {
@:uname("new") static function createNew():POwnedPtr<FOnlineLeaderboardWrite>;
  public var LeaderboardNames : TArray<FName>;
}
