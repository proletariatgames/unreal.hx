package unreal;

extern class ULevel_Extra {
  /** URL associated with this level. */
  var URL : FURL;

  var Actors:TArray<AActor>;

  @:thisConst
  public function GetLevelScriptActor() : ALevelScriptActor;
}
