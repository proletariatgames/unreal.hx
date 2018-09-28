package unreal;


/** Delegate fired when an AutoLogin request is complete */
@:glueCppIncludes('OnlineEngineInterface.h')
@:uname('FOnlineAutoLoginComplete')
@:uParamName("LocalUserNum") @:uParamName("bWasSuccessful") @:uParamName("Error")
typedef FOnlineAutoLoginComplete = Delegate<FOnlineAutoLoginComplete, Int32->Bool->Const<PRef<FString>>->Void>;

/** Delegate fired when an online StartSession call has completed */
@:glueCppIncludes('OnlineEngineInterface.h')
@:uname('FOnlineSessionStartComplete')
@:uParamName("InSessionName") @:uParamName("bWasSuccessful")
typedef FOnlineSessionStartComplete = Delegate<FOnlineSessionStartComplete, FName->Bool->Void>;

/** Delegate fired when an online EndSession call has completed */
@:glueCppIncludes('OnlineEngineInterface.h')
@:uname('FOnlineSessionEndComplete')
@:uParamName("InSessionName") @:uParamName("bWasSuccessful")
typedef FOnlineSessionEndComplete = Delegate<FOnlineSessionEndComplete, FName->Bool->Void>;

	/**
	 * Called when a user receives a session invitation. Allows the game code to decide
	 * on accepting the invite. The invite can be accepted by calling JoinSession()
	 *
	 * @param UserId the user being invited
	 * @param FromId the user that sent the invite
	 * @param AppId the id of the client/app user was in when sending hte game invite
	 * @param InviteResult the search/settings for the session we're joining via invite
	 */
@:glueCppIncludes('OnlineSessionInterface.h')
@:uname('FOnSessionInviteReceived')
@:uParamName("UserId") @:uParamName("FromId") @:uParamName("AppID") @:uParamName("InviteResult")
typedef FOnSessionInviteReceived = MulticastDelegate<FOnSessionInviteReceived, Const<PRef<FUniqueNetId>>->Const<PRef<FUniqueNetId>>->Const<PRef<FString>>->Const<PRef<FOnlineSessionSearchResult>>->Void>;

@:glueCppIncludes('OnlineSessionInterface.h')
@:uname("FOnSessionInviteReceived.FDelegate")
@:uParamName("UserId") @:uParamName("FromId") @:uParamName("AppID") @:uParamName("InviteResult")
typedef FOnSessionInviteReceivedDelegate = unreal.Delegate<FOnSessionInviteReceivedDelegate, Const<PRef<FUniqueNetId>>->Const<PRef<FUniqueNetId>>->Const<PRef<FString>>->Const<PRef<FOnlineSessionSearchResult>>->Void>;

/**
 * Delegate fired when the search for an online session has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
@:glueCppIncludes('OnlineSessionInterface.h')
@:uname('FOnFindSessionsComplete')
@:uParamName("bSuccess")
typedef FOnFindSessionsComplete = MulticastDelegate<FOnFindSessionsComplete, Bool->Void>;

@:glueCppIncludes('OnlineSessionInterface.h')
@:uname("FOnFindSessionsComplete.FDelegate")
@:uParamName("bSuccess")
typedef FOnFindSessionsCompleteDelegate = unreal.Delegate<FOnFindSessionsCompleteDelegate, Bool->Void>;

/**
 * Delegate fired when the cancellation of a search for an online session has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
@:glueCppIncludes('OnlineSessionInterface.h')
@:uname('FOnCancelFindSessionsComplete')
@:uParamName("bSuccess")
typedef FOnCancelFindSessionsComplete = MulticastDelegate<FOnCancelFindSessionsComplete, Bool->Void>;

@:glueCppIncludes('OnlineSessionInterface.h')
@:uname("FOnCancelFindSessionsComplete.FDelegate")
@:uParamName("bSuccess")
typedef FOnCancelFindSessionsCompleteDelegate = unreal.Delegate<FOnCancelFindSessionsCompleteDelegate, Bool->Void>;

@:glueCppIncludes("OnlineSessionInterface.h")
@:uextern @:noCopy @:noEquals @:noClass extern class IOnlineSession {
	public function CreateSession(HostingPlayerNum:Int32, SessionName:FName, NewSession:Const<PRef<FOnlineSessionSettings>>) : Bool;
	public function EndSession(SessionName:FName) : Bool;
	/**
	 * Searches the named session array for the specified session
	 *
	 * @param SessionName the name to search for
	 *
	 * @return pointer to the struct if found, NULL otherwise
	 */
	public function GetNamedSession(SessionName:FName) : PPtr<FNamedOnlineSession>;

	public function AddOnSessionInviteReceivedDelegate_Handle(Delegate:Const<PRef<FOnSessionInviteReceivedDelegate>>) : FDelegateHandle;
	public function ClearOnSessionInviteReceivedDelegate_Handle(Handle:PRef<FDelegateHandle>) : Void;
}
