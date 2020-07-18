package unreal.onlinesubsystem;

extern class IOnlineExternalUI_Extra {
	/**
		* Displays a user's profile card.
		*
		* @param Requestor The user requesting the profile.
		* @param Requestee The user for whom to show the profile.
		*
		* @return true if it was able to show the UI, false if it failed
	*/
	public function ShowProfileUI(Requestor:unreal.Const<unreal.PRef<unreal.FUniqueNetId>>, Requestee:unreal.Const<unreal.PRef<unreal.FUniqueNetId>>) : Bool;

	public function ReportEnterInGameStoreUI():Void;
	public function ReportExitInGameStoreUI():Void;

}
