package unreal.onlinesubsystemutils;

extern class UOnlineSessionClient_Extra {
	private function OnSessionUserInviteAccepted(bWasSuccessful:Const<Bool>, ControllerId:Const<Int32>, UserId:TSharedPtr<Const<FUniqueNetId>>, InviteResult:Const<PRef<FOnlineSessionSearchResult>>):Void;
}
