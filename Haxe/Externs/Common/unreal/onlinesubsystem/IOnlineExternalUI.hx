package unreal.onlinesubsystem;

import unreal.*;

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
	public function ShowInviteUI(LocalUserNum:unreal.Int32, ?SessionName:FName = UnrealName.NAME_GameSession) : Bool;
}
