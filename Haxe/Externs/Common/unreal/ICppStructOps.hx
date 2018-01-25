package unreal;

@:glueCppIncludes("UObject/Class.h")
@:uname("UScriptStruct::ICppStructOps")
@:noCopy
@:uextern extern class ICppStructOps {
	function HasZeroConstructor():Bool;
	function Construct(Dest:AnyPtr):Void;
	function GetSize():Int;
	function GetAlignment():Int;
	function HasCopy():Bool;
	function Copy(Dest:AnyPtr, Src:AnyPtr, ArrayDim:Int):Bool;
}