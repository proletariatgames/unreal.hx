package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class FWorldContext {
  var ContextHandle:FName;

  /** URL to travel to for pending client connect */
  var TravelURL:FString;

  /** TravelType for pending client connects */
  var TravelType:UInt8;

  /** URL the last time we traveled */
  var LastURL:FURL;

  /** last server we connected to (for "reconnect" command) */
  var LastRemoteURL:FURL;

  var PendingNetGame:UPendingNetGame;

  var PIEInstance:Int32;

  var PIEPrefix:FString;

  var PIERemapPrefix:FString;

  var RunAsDedicated:Bool;

  var WorldType:EWorldType;

  function World():UWorld;
}
