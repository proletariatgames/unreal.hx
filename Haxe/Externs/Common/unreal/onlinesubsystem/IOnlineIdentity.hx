package unreal.onlinesubsystem;

import unreal.*;

/**
 * Called when user account login has completed after calling Login() or AutoLogin()
 *
 * @param LocalUserNum the controller number of the associated user
 * @param bWasSuccessful true if server was contacted and a valid result received
 * @param UserId the user id received from the server on successful login
 * @param Error string representing the error condition
 */
@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum") @:uParamName("bWasSuccessful") @:uParamName("UserId") @:uParamName("Error")
typedef FOnLoginComplete = unreal.MulticastDelegate<FOnLoginComplete, Int32->Bool->Const<PRef<FUniqueNetId>>->Const<PRef<FString>>->Void>;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum") @:uParamName("bWasSuccessful") @:uParamName("UserId") @:uParamName("Error")
typedef FOnLoginCompleteDelegate = unreal.Delegate<FOnLoginCompleteDelegate, Int32->Bool->Const<PRef<FUniqueNetId>>->Const<PRef<FString>>->Void>;

/**
 * Delegate called when a player logs in/out
 *
 * @param LocalUserNum the player that logged in/out
 */
@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum")
typedef FOnLoginChanged = unreal.MulticastDelegate<FOnLoginChanged, Int32->Void>;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum")
typedef FOnLoginChangedDelegate = unreal.Delegate<FOnLoginChangedDelegate, Int32->Void>;

/**
 * Delegate called when a player's status changes but doesn't change profiles
 *
 * @param LocalUserNum the controller number of the associated user
 * @param OldStatus the old login status for the user
 * @param NewStatus the new login status for the user
 * @param NewId the new id to associate with the user
 */
@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum") @:uParamName("OldStatus") @:uParamName("NewStatus") @:uParamName("NewId")
typedef FOnLoginStatusChanged = unreal.MulticastDelegate<FOnLoginStatusChanged, Int32->ELoginStatus->ELoginStatus->Const<PRef<FUniqueNetId>>->Void>;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum") @:uParamName("OldStatus") @:uParamName("NewStatus") @:uParamName("NewId")
typedef FOnLoginStatusChangedDelegate = unreal.Delegate<FOnLoginStatusChangedDelegate, Int32->ELoginStatus->ELoginStatus->Const<PRef<FUniqueNetId>>->Void>;

/**
 * Delegate used in notifying the that manual logout completed
 *
 * @param LocalUserNum the controller number of the associated user
 * @param bWasSuccessful whether the async call completed properly or not
 */
@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum") @:uParamName("bWasSuccessful")
typedef FOnLogoutComplete = unreal.MulticastDelegate<FOnLogoutComplete, Int32->Bool->Void>;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("LocalUserNum") @:uParamName("bWasSuccessful")
typedef FOnLogoutCompleteDelegate = unreal.Delegate<FOnLogoutCompleteDelegate, Int32->Bool->Void>;

/**
 * Delegate executed when we get a user privilege result.
 *
 * @param UniqueId The unique id of the user who was queried
 * @param Privilege the privilege that was queried
 * @param PrivilegeResult bitwise OR of any privilege failures. 0 is success.
 */
@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uname("IOnlineIdentity.FOnGetUserPrivilegeCompleteDelegate")
@:uParamName("UniqueId") @:uParamName("Privilege") @:uParamName("PrivilegeResult")
typedef FOnGetUserPrivilegeCompleteDelegate = unreal.Delegate<FOnGetUserPrivilegeCompleteDelegate, Const<PRef<FUniqueNetId>>->EUserPrivileges->FakeUInt32->Void>;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class IOnlineIdentity {
	public function GetAuthToken(localUserNum:Int32):FString;
	public function GetLoginStatus(localUserNum:Int32):ELoginStatus;
	public function GetPlayerNickname(localUserNum:Int32):FString;
	public function Login(LocalUserNum:Int32, Credentials:FOnlineAccountCredentials):Bool;

	/**
	 * Gets the status of a user's privilege.
	 *
	 * @param LocalUserId the unique id of the user to query
	 * @param Privilege the privilege you want to know about
	 * @param Delegate delegate to execute when the async task completes
	 */
	public function GetUserPrivilege(LocalUserId:Const<PRef<FUniqueNetId>>, Privilege:EUserPrivileges, Delegate:Const<PRef<FOnGetUserPrivilegeCompleteDelegate>>) : Void;

	/**
	 * Gets the platform specific unique id for the specified player
	 *
	 * @param LocalUserNum the controller number of the associated user
	 *
	 * @return Valid player id object if the call succeeded, NULL otherwise
	 */
	@:thisConst
	public function GetUniquePlayerId(LocalUserNum : unreal.Int32) : TSharedPtr<Const<FUniqueNetId>>;

	/**
	 * Create a unique id from string
	 *
	 * @param Str string holding textual representation of an Id
	 *
	 * @return UniqueId from the given data, NULL otherwise
	 */
	public function CreateUniquePlayerId(Str: PRef<Const<FString>>): TSharedPtr<Const<FUniqueNetId>>;

	/**
	 * OnLoginComplete helpers
	 **/
	public function AddOnLoginCompleteDelegate_Handle(LocalUserNum:Int32, Delegate:Const<PRef<FOnLoginCompleteDelegate>>) : FDelegateHandle;
	public function ClearOnLoginCompleteDelegate_Handle(LocalUserNum:Int32, Handle:PRef<FDelegateHandle>) : Void;

	/**
	 * OnLoginChanged helpers
	 **/
	public function AddOnLoginChangedDelegate_Handle(Delegate:Const<PRef<FOnLoginChangedDelegate>>) : FDelegateHandle;
	public function ClearOnLoginChangedDelegate_Handle(Handle:PRef<FDelegateHandle>) : Void;

	/**
	 * OnLoginStatusChanged helpers
	 **/
	public function AddOnLoginStatusChangedDelegate_Handle(LocalUserNum:Int32, Delegate:Const<PRef<FOnLoginStatusChangedDelegate>>) : FDelegateHandle;
	public function ClearOnLoginStatusChangedDelegate_Handle(LocalUserNum:Int32, Handle:PRef<FDelegateHandle>) : Void;

	/**
	 * OnLogoutComplete helpers
	 **/
	public function AddOnLogoutCompleteDelegate_Handle(LocalUserNum:Int32, Delegate:Const<PRef<FOnLogoutCompleteDelegate>>) : FDelegateHandle;
	public function ClearOnLogoutCompleteDelegate_Handle(LocalUserNum:Int32, Handle:PRef<FDelegateHandle>) : Void;
}
