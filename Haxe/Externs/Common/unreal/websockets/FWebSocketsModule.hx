package unreal.websockets;

@:glueCppIncludes("WebSocketsModule.h")
@:umodule("WebSockets")
@:uextern extern class FWebSocketsModule
{
	/**
	 * Singleton-like access to this module's interface.  This is just for convenience!
	 * Beware of calling this during the shutdown phase, though.  Your module might have been unloaded already.
	 *
	 * @return Returns singleton instance, loading the module on demand if needed
	 */
	static public function Get():PRef<FWebSocketsModule>;

	/**
	 * Instantiates a new web socket for the current platform
	 *
	 * @param Url The URL to which to connect; this should be the URL to which the WebSocket server will respond.
	 * @param Protocols a list of protocols the client will handle.
	 * @return new IWebSocket instance
	 */
	public function CreateWebSocket(Url:Const<PRef<FString>>, Protocols:Const<PRef<TArray<FString>>>, @:opt(TMap.create()) ?UpgradeHeaders:Const<PRef<TMap<FString, FString>>>):TSharedRef<IWebSocket>;


	/**
	 * Instantiates a new web socket for the current platform
	 *
	 * @param Url The URL to which to connect; this should be the URL to which the WebSocket server will respond.
	 * @param Protocol an optional sub-protocol. If missing, an empty string is assumed.
	 * @return new IWebSocket instance
	 */
	@:uname("CreateWebSocket") public function CreateWebSocketWithProtocol(Url:Const<PRef<FString>>, @:opt("") ?Protocol:Const<PRef<FString>>, @:opt(TMap.create()) ?UpgradeHeaders:Const<PRef<TMap<FString, FString>>>):TSharedRef<IWebSocket>;
}
