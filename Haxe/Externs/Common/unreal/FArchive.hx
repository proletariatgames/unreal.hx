package unreal;

@:glueCppIncludes('Serialization/Archive.h')
@:uextern extern class FArchive {
  public function new();

  function Preload(obj:UObject):Void;
  function Tell():Int64;
  function TotalSize():Int64;
  function AtEnd():Bool;
  function Seek(pos:Int64):Void;
  function FlushCache():Void;
  function Close():Bool;
  function GetError():Bool;
  function SetError():Void;
}
