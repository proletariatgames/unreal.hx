package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class IOnlineIdentity {
  public function GetAuthToken(localUserNum:Int32):FString;
  public function GetLoginStatus(localUserNum:Int32):ELoginStatus;
}
