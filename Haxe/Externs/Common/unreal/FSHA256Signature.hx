package unreal;

@:glueCppIncludes("HAL/PlatformMisc.h")
@:noEquals @:noCopy @:uextern extern class FSHA256Signature
{
  function new();

  // we cannot extern this yet
  // uint8 Signature[32];
  var Signature(default, never):ConstAnyPtr;

  /** Generates a hex string of the signature */
  function ToString():FString;
}
