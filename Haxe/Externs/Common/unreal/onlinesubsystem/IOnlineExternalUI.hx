package unreal.onlinesubsystem;

import unreal.*;

/**
 * Delegate executed when the external login UI has been closed.
 *
 * @param UniqueId The unique id of the user who signed in. Null if no user signed in.
 * @param ControllerIndex The controller index of the controller that activated the login UI.
 * @param Error any errors related to closing the UI
 */
@:glueCppIncludes("OnlineExternalUIInterface.h") @:umodule("OnlineSubsystem")
typedef FOnLoginUIClosedDelegate = Delegate<FOnLoginUIClosedDelegate,
	(UniqueId:TSharedPtr<Const<FUniqueNetId>>, ControllerIndex:Int32, Error:Const<PRef<FOnlineError>>)->Void
>;

@:glueCppIncludes("OnlineExternalUIInterface.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class IOnlineExternalUI {

	/**
	 * Displays the UI that shows a user's list of friends
	 *
	 * @param LocalUserNum the controller number of the associated user
	 *
	 * @return true if it was able to show the UI, false if it failed
	 */
	public function ShowFriendsUI(LocalUserNum:unreal.Int32) : Bool;

  /**
	 *	Displays the UI that shows a user's list of friends to invite
	 *
	 * @param LocalUserNum the controller number of the associated user
	 * @param SessionName name of session associated with the invite
	 *
	 * @return true if it was able to show the UI, false if it failed
	 */
	public function ShowInviteUI(LocalUserNum:unreal.Int32, @:opt(UnrealName.NAME_GameSession) ?SessionName:FName) : Bool;

	/**
	 * Displays an informational system dialog.
	 *
	 * @param UserId Who to show this dialog for.
	 * @param MessageId Platform-specific identifier for the message box to display.
	 */
	 public function ShowPlatformMessageBox(UserId:Const<PRef<FUniqueNetId>> , MessageType:EPlatformMessageType) : Bool;

		/**
	 * Displays the UI that prompts the user for their login credentials. Each
	 * platform handles the authentication of the user's data.
	 *
	 * @param ControllerIndex The controller that prompted showing the login UI. If the platform supports it,
	 * it will pair the signed-in user with this controller.
	 * @param bShowOnlineOnly whether to only display online enabled profiles or not
	 * @param bShowSkipButton On platforms that support it, display the "Skip" button
	 * @param Delegate The delegate to execute when the user closes the login UI.
	 *
	 * @return true if it was able to show the UI, false if it failed
	 */
	 public function ShowLoginUI(ControllerIndex:unreal.Int32, bShowOnlineOnly:Bool, bShowSkipButton:Bool, Delegate:Const<PRef<FOnLoginUIClosedDelegate>>) : Bool;

}
