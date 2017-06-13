package unreal;

@:glueCppIncludes("Engine/World.h")
@:noCopy @:noEquals
@:uextern extern class UWorldProxy {
  function GetReference() : UWorld;
}