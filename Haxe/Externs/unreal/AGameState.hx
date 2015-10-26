package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class AGameState extends AInfo {

  /** Array of all PlayerStates, maintained on both server and clients (PlayerStates are always relevant) */
  @:uproperty(BlueprintReadOnly, Category=GameState)
  var PlayerArray:PStruct<TArray<PStruct<APlayerState>>>;
}
