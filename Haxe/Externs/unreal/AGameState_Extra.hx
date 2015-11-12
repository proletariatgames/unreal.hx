package unreal;

extern class AGameState_Extra {
  /**
    Returns the current match state, this is an accessor to protect the state machine flow
   **/
  @:thisConst
  function GetMatchState () : PStruct<FName>;
}
