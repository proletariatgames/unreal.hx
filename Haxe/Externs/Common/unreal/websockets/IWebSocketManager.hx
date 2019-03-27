package unreal.websockets;

@:glueCppIncludes("IWebSocketsManager.h")
@:umodule("WebSockets")
@:noCopy
@:uextern extern class IWebSocketsManager
{
	// /**
	//  * Web sockets start-up: call before creating any web sockets
	//  */
	// public function InitWebSockets(TArrayView<const FString> Protocols):Void;


	/**
	 * Web sockets teardown: call at shutdown, in particular after all use of SSL has finished
	 */
	public function ShutdownWebSockets():Void;

	/**
	 * Instantiates a new web socket for the current platform
	 *
	 * @param Url The URL to which to connect; this should be the URL to which the WebSocket server will respond.
	 * @param Protocols a list of protocols the client will handle.
	 * @return new IWebSocket instance
	 */
	public function CreateWebSocket(Url:Const<PRef<FString>>, Protocols:Const<PRef<TArray<FString>>>, UpgradeHeaders:Const<PRef<TMap<FString, FString>>>):TSharedRef<IWebSocket>;
}
