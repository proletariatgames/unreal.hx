package unreal;

extern class AGameSession_Extra
{
	public function HandleStartMatchRequest() : Bool;
	public function HandleMatchIsWaitingToStart() : Void;
	public function HandleMatchHasStarted() : Void;
	public function HandleMatchHasEnded() : Void;
	public function KickPlayer(kickerPlayer:APlayerController, kickReason:Const<PRef<FText>>):Bool;

	/** Initialize options based on passed in options string */
	public function InitOptions(Options:Const<PRef<FString>>) : Void;

	/** Allow a dedicated server a chance to register itself with an online service */
	public function RegisterServer() : Void;

	/** Callback when autologin was expected but failed */
	public function RegisterServerFailed() : Void;

	/**
	 * Register a player with the online service session
	 * @param NewPlayer player to register
	 * @param UniqueId uniqueId they sent over on Login
	 * @param bWasFromInvite was this from an invite
	 */
	public function RegisterPlayer(NewPlayer:APlayerController, UniqueId:Const<PRef<TSharedPtr<Const<FUniqueNetId>>>>, bWasFromInvite:Bool) : Void;

	/** @return true if there is no room on the server for an additional player */
	public function AtCapacity(bSpectator:Bool):Bool;
}
