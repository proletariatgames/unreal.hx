package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineStats.h") @:umodule("OnlineSubsystem")
@:uname("FOnlineAchievementsWrite")
@:noCopy
@:uextern extern class FOnlineAchievementsWrite extends FOnlineStats {
@:uname("new") static function createNew():POwnedPtr<FOnlineAchievementsWrite>;

}
