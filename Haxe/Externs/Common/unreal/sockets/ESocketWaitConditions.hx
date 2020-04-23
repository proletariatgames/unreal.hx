package unreal.sockets;

@:glueCppIncludes("SocketTypes.h")
@:uname("ESocketWaitConditions.Type")
@:uextern extern enum ESocketWaitConditions
{
  /**
    * Wait until data is available for reading.
    */
  WaitForRead;

  /**
    * Wait until data can be written.
    */
  WaitForWrite;

  /**
    * Wait until data is available for reading or can be written.
    */
  WaitForReadOrWrite;
}