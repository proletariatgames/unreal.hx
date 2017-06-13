package unreal;

@:glueCppIncludes("ModuleManager.h")
@:noCopy @:noEquals @:uextern extern class FModuleStatus {
  function new();

  var Name:FString;
  var FilePath:FString;
  var bIsLoaded:Bool;
  var bIsGameModule:Bool;
}

