package unreal.onlinesubsystem;

import unreal.*;


@:glueCppIncludes("Online.h") @:umodule("OnlineSubsystem")
@:uname("IOnlineSubsystem")
@:noCopy
@:uextern extern class IOnlineSubsystem {
  public static function Get(subsystemName:FName) : unreal.PPtr<IOnlineSubsystem>;

  public function GetAchievementsInterface() : unreal.TThreadSafeSharedPtr<IOnlineAchievements>;
  public function GetLeaderboardsInterface() : unreal.TThreadSafeSharedPtr<IOnlineLeaderboards>;
  public function GetIdentityInterface() : unreal.TThreadSafeSharedPtr<IOnlineIdentity>;
  public function GetInstanceName() : FName;

  public function GetLanguage() : FString;
  public function IsSteamControllerActive() : Bool;
}
