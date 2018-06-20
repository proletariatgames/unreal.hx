package unreal.websockets;

@:uname("IWebSocket.FWebSocketConnectedEvent")
@:umodule("WebSockets")
@:glueCppIncludes("IWebSocket.h")
typedef FWebSocketConnectedEvent = Event<FWebSocketConnectedEvent, Void->Void>;

@:uname("IWebSocket.FWebSocketConnectionErrorEvent")
@:umodule("WebSockets")
@:glueCppIncludes("IWebSocket.h")
typedef FWebSocketConnectionErrorEvent = Event<FWebSocketConnectionErrorEvent, /* Error */Const<PRef<FString>>->Void>;

@:uname("IWebSocket.FWebSocketClosedEvent")
@:umodule("WebSockets")
@:glueCppIncludes("IWebSocket.h")
typedef FWebSocketClosedEvent = Event<FWebSocketClosedEvent, /* StatusCode */ Int->/* Reason */Const<PRef<FString>>->/*bWasClean*/Bool->Void>;

@:uname("IWebSocket.FWebSocketMessageEvent")
@:umodule("WebSockets")
@:glueCppIncludes("IWebSocket.h")
typedef FWebSocketMessageEvent = Event<FWebSocketMessageEvent, /* MessageString */Const<PRef<FString>>->Void>;

@:uname("IWebSocket.FWebSocketRawMessageEvent")
@:umodule("WebSockets")
@:glueCppIncludes("IWebSocket.h")
typedef FWebSocketRawMessageEvent = Event<FWebSocketRawMessageEvent , /* Data */ConstAnyPtr->/* Size */SizeT->/* BytesRemaining */SizeT->Void>;

@:glueCppIncludes("IWebSocket.h")
@:umodule("WebSockets")
@:noCopy
@:uextern extern class IWebSocket
{
	/**
	 * Initiate a client connection to the server.
	 * Use this after setting up event handlers or to reconnect after connection errors.
	 */
	public function Connect():Void;

	/**
	 * Close the current connection.
	 * @param Code Numeric status code explaining why the connection is being closed. Default is 1000. See WebSockets spec for valid codes.
	 * @param Reason Human readable string explaining why the connection is closing.
	 */
	public function Close(Code:Int = 1000, @:opt("") ?Reason:Const<PRef<FString>>):Void;

	/**
	 * Inquire if this web socket instance is connected to a server.
	 */
	public function IsConnected():Bool;

	/**
	 * Transmit data over the connection.
	 * @param Data data to be sent as a UTF-8 encoded string.
	 */
	public function Send(Data:Const<PRef<FString>>):Void;

	/**
	 * Transmit data over the connection.
	 * @param Data raw binary data to be sent.
	 * @param Size number of bytes to send.
	 * @param bIsBinary set to true to send binary frame to the peer instead of text.
	 */
	@:uname("Send") public function SendRaw(Data:AnyPtr, Size:Int, bIsBinary:Bool = false):Void;

	/**
	 * Delegate called when a web socket connection has been established successfully.
	 *
	 */
	 public function OnConnected():PRef<FWebSocketConnectedEvent>;

	/**
	 * Delegate called when a web socket connection could not be established.
	 *
	 */
	public function OnConnectionError():PRef<FWebSocketConnectionErrorEvent>;

	/**
	 * Delegate called when a web socket connection has been closed.
	 *
	 */
	public function OnClosed():PRef<FWebSocketClosedEvent>;

	/**
	 * Delegate called when a web socket text message has been received.
	 * Assumes the payload is encoded as UTF8. For binary data, bind to OnRawMessage instead.
	 *
	 */
	public function OnMessage():PRef<FWebSocketMessageEvent>;

	/**
	 * Delegate called when a web socket data has been received.
	 * May be called multiple times for a message if the message was split into multiple frames.
	 * The last parameter will be 0 on the last frame in the packet.
	 *
	 */
	public function OnRawMessage():PRef<FWebSocketRawMessageEvent>;
}
