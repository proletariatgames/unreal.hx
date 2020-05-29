package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("Online.h") @:umodule("OnlineSubsystem")

typedef FOnQueryAchievementsCompleteDelegate = unreal.Delegate<FOnQueryAchievementsCompleteDelegate, unreal.PRef<unreal.Const<unreal.FUniqueNetId>>->Bool->Void>;



@:uname("IOnlineAchievements")
@:glueCppIncludes("Online.h")
@:noCopy
@:uextern extern class IOnlineAchievements {
  public function WriteAchievements( playerId : unreal.PRef<unreal.Const<FUniqueNetId>>, writeObject : unreal.TThreadSafeSharedRef<FOnlineAchievementsWrite>) : Void;
  public function QueryAchievements( playerId : unreal.PRef<unreal.Const<FUniqueNetId>>, delegate : FOnQueryAchievementsCompleteDelegate ) : Void;
	public function GetCachedAchievement( playerId : unreal.PRef<unreal.Const<FUniqueNetId>>, AchievementId : FString, OutAchievement:FOnlineAchievement ) : EOnlineCachedResult;
	public function GetCachedAchievements( playerId : unreal.PRef<unreal.Const<FUniqueNetId>>, OutAchievements:TArray<FOnlineAchievement>) : EOnlineCachedResult;
}
