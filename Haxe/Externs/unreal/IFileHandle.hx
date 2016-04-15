package unreal;

@:glueCppIncludes("GenericPlatformFile.h")
@:noCopy @:noEquals
@:uextern extern class IFileHandle {
  function Read(dest:ByteArray, bytesToRead:Int64):Bool;
  function Seek(newPosition:Int64):Bool;
  function SeekFromEnd(newPosition:Int64):Bool;
  function Size():Int64;
  function Tell():Int64;
  function Write(source:ByteArray, bytesToWrite:Int64):Bool;
}
