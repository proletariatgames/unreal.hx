package unreal;

extern class FWorldContext_Extra {
  var ContextHandle:FName;

  /** URL to travel to for pending client connect */
  var TravelURL:FString;

  /** TravelType for pending client connects */
  var TravelType:UInt8;

  var PIEInstance:Int32;

  var PIEPrefix:FString;

  var PIERemapPrefix:FString;

  var RunAsDedicated:Bool;

  var WorldType:EWorldType;

  function World():UWorld;
}
