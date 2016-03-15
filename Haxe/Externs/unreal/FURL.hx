package unreal;

@:glueCppIncludes("Engine/EngineBaseTypes.h")
@:uextern extern class FURL {
  /**
    Protocol, i.e. unreal or http
   **/
  var Protocol:FString;

  /**
    Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
   **/
  var Host:FString;

  /**
    Optional host port
   **/
  var Port:Int32;

  /**
    Map name, i.e. "SkyCity", default is "Entry"
   **/
  var Map:FString;

  /**
    Optional place to download Map if client does not possess it
   **/
  var RedirectURL:FString;

  /**
    Options
   **/
  var Op:TArray<FString>;

  /**
    Portal to enter through, default is ""
   **/
  var Portal:FString;

  var Valid:Int32;
}
