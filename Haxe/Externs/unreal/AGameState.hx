package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class AGameState extends AInfo {

  /** Array of all PlayerStates, maintained on both server and clients (PlayerStates are always relevant) */
  @:uproperty(BlueprintReadOnly, Category=GameState)
  var PlayerArray:PStruct<TArray<PStruct<APlayerState>>>;

  /** Returns the current match state, this is an accessor to protect the state machine flow */
  @:ufunction
  @:thisConst
  function GetMatchState () : PStruct<FName>;
}
