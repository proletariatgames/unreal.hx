package unreal;

extern class UPendingNetGame_Extra
{
	/** URL associated with this level. */
	public var URL:FURL;

	/** @todo document */
	public var bSuccessfullyConnected:Bool;

	/** @todo document */
	public var bSentJoinRequest:Bool;

	/** @todo document */
	public var ConnectionError:FString;

	/** Send JOIN to other end */
	public function SendJoin() : Void;

	/** Called by the engine after it calls LoadMap for this PendingNetGame. */
	public function LoadMapCompleted(Engine:UEngine, Context:PRef<FWorldContext>, bLoadedMapSuccessfully:Bool, LoadMapError:PRef<Const<FString>>) : Void;
}

