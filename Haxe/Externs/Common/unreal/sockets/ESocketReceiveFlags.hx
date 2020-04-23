package unreal.sockets;

@:glueCppIncludes("SocketTypes.h")
@:uname("ESocketReceiveFlags.Type")
@:uextern extern enum ESocketReceiveFlags
{
  /**
    * Return as much data as is currently available in the input queue,
    * up to the specified size of the receive buffer.
    */
  None;

  /**
    * Copy received data into the buffer without removing it from the input queue.
    */
  Peek;

  /**
    * Block the receive call until either the supplied buffer is full, the connection
    * has been closed, the request has been canceled, or an error occurred.
    */
  WaitAll;
}