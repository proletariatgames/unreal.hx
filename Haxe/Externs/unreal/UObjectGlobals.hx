package unreal;

@:glueCppIncludes("UObject/UObjectGlobals.h")
@:uextern extern class UObjectGlobals {
  @:global public static function IsGarbageCollecting():Bool;
}
