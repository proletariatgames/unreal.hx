package unreal;

@:glueCppIncludes("GenericPlatformFile.h")
@:noCopy @:noEquals
@:uextern extern class IFileHandle {
  @:ublocking function Read(dest:ByteArray, bytesToRead:Int64):Bool;
  @:ublocking @:uname("Read") function ReadPtr(dest:Ptr<UInt8>, bytesToRead:Int64):Bool;
  @:ublocking function Seek(newPosition:Int64):Bool;
  @:ublocking function SeekFromEnd(newPosition:Int64):Bool;
  @:ublocking function Size():Int64;
  @:ublocking function Tell():Int64;
  @:ublocking function Write(source:ByteArray, bytesToWrite:Int64):Bool;
  @:ublocking function Flush():Void;
  @:ublocking @:uname("Write") function WritePtr(source:Ptr<UInt8>, bytesToWrite:Int64):Bool;
}
