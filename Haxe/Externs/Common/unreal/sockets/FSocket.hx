package unreal.sockets;

@:glueCppIncludes("Sockets.h")
@:noCopy @:noEquals
@:uextern extern class FSocket
{
  /**
    * Closes the socket
    *
    * @return true if it closes without errors, false otherwise.
    */
  function Close():Bool;

  /**
    * Blocks until the specified condition is met.
    *
    * @param Condition The condition to wait for.
    * @param WaitTime The maximum time to wait.
    * @return true if the condition was met, false if the time limit expired or an error occurred.
    */
  function Wait(Condition:ESocketWaitConditions, WaitTime:FTimespan):Bool;

  /**
    * Reads a chunk of data from the socket and gathers the source address.
    *
    * A return value of 'true' does not necessarily mean that data was returned.
    * Callers must check the 'BytesRead' parameter for the actual amount of data
    * returned. A value of zero indicates that there was no data available for reading.
    *
    * @param Data The buffer to read into.
    * @param BufferSize The max size of the buffer.
    * @param BytesRead Will indicate how many bytes were read from the socket.
    * @param Source Will contain the receiving the address of the sender of the data.
    * @param Flags The receive flags.
    * @return true on success, false in case of a closed socket or an unrecoverable error.
    */
  function RecvFrom(Data:ByteArray, BufferSize:Int32, BytesRead:Ref<Int32>, Source:PRef<FInternetAddr>, Flags:ESocketReceiveFlags = ESocketReceiveFlags.None):Bool;

  /**
    * Queries the socket to determine if there is a pending connection.
    *
    * @param bHasPendingConnection Will indicate whether a connection is pending or not.
    * @return true if successful, false otherwise.
    */
  function HasPendingConnection(bHasPendingConnection:Ref<Bool>):Bool;

  /**
  * Queries the socket to determine if there is pending data on the queue.
  *
  * @param PendingDataSize Will indicate how much data is on the pipe for a single recv call.
  * @return true if the socket has data, false otherwise.
  */
  function HasPendingData(PendingDataSize:Ref<UInt>):Bool;

	/**
	 * Sends a buffer to a network byte ordered address.
	 *
	 * @param Data The buffer to send.
	 * @param Count The size of the data to send.
	 * @param BytesSent Will indicate how much was sent.
	 * @param Destination The network byte ordered address to send to.
	 */
	function SendTo(Data:ByteArray, Count:Int32, BytesSent:Ref<Int32>, Destination:Const<PRef<FInternetAddr>>):Bool;
}
