package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineAchievementsInterface.h") @:umodule("OnlineSubsystem")

typedef FOnQueryAchievementsCompleteDelegate = unreal.Delegate<FOnQueryAchievementsCompleteDelegate, unreal.PRef<unreal.Const<unreal.FUniqueNetId>>->Bool->Void>;



@:uname("IOnlineAchievements")
@:glueCppIncludes("OnlineAchievementsInterface.h")
@:noCopy
@:uextern extern class IOnlineAchievements {
  public function WriteAchievements( playerId : unreal.PRef<unreal.Const<FUniqueNetId>>, writeObject : unreal.TThreadSafeSharedRef<FOnlineAchievementsWrite>) : Void;
  public function QueryAchievements( playerId : unreal.PRef<unreal.Const<FUniqueNetId>>, delegate : FOnQueryAchievementsCompleteDelegate ) : Void;
}
