package unreal;

@:glueCppIncludes('OnlineSessionInterface.h')
@:uname('FOnSessionInviteReceived')
@:uParamName("UserId") @:uParamName("FromId") @:uParamName("AppID") @:uParamName("InviteResult")
typedef FOnSessionInviteReceived = MulticastDelegate<FOnSessionInviteReceived, Const<PRef<FUniqueNetId>>->Const<PRef<FUniqueNetId>>->Const<PRef<FString>>->Const<PRef<FOnlineSessionSearchResult>>->Void>;

@:glueCppIncludes('OnlineSessionInterface.h')
@:uname("FOnSessionInviteReceived.FDelegate")
@:uParamName("UserId") @:uParamName("FromId") @:uParamName("AppID") @:uParamName("InviteResult")
typedef FOnSessionInviteReceivedDelegate = unreal.Delegate<FOnSessionInviteReceivedDelegate, Const<PRef<FUniqueNetId>>->Const<PRef<FUniqueNetId>>->Const<PRef<FString>>->Const<PRef<FOnlineSessionSearchResult>>->Void>;

@:glueCppIncludes("OnlineSessionInterface.h")
@:uextern @:noCopy @:noEquals @:noClass extern class IOnlineSession {
  public function CreateSession(HostingPlayerNum:Int32, SessionName:FName, NewSession:Const<PRef<FOnlineSessionSettings>>) : Bool;
  public function EndSession(SessionName:FName) : Bool;

  public function AddOnSessionInviteReceivedDelegate_Handle(Delegate:Const<PRef<FOnSessionInviteReceivedDelegate>>) : FDelegateHandle;
}
