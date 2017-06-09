package unreal;

@:glueCppIncludes("UObject/CoreNet.h")
@:noEquals @:noCopy
@:uextern extern class IRepChangedPropertyTracker {
  function SetCustomIsActiveOverride(RepIndex:UInt16, bIsActive:Bool):Void;
  function SetExternalData(Src:ByteArray, NumBits:Int32):Void;
  function IsReplay():Bool;
}
