package unreal;

@:glueCppIncludes("Containers/Array.h")
@:uextern extern class FScriptArray {
  function GetData():AnyPtr;
  function IsValidIndex(i:Int):Bool;
  function Num():Int;
  function Add(count:Int, numBytesPerElement:Int):Int;
  function AddZeroed(count:Int, numBytesPerElement:Int):Int;
  function Insert(index:Int, count:Int, numBytesPerElement:Int):Void;
  function Empty(slack:Int, numBytesPerElement:Int):Void;
}
