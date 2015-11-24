package unreal;

extern class AController_Extra {
  public function PawnPendingDestroy(inPawn:APawn) : Void;

  @:thisConst
  public function GetCharacter() : ACharacter;

  @:thisConst
  public function GetPawn() : APawn;

  public function ChangeState(newState:FName) : Void;

  /**
   * Called from game mode upon end of the game, used to transition to proper state. 
   * @param EndGameFocus Actor to set as the view target on end game
   * @param bIsWinner true if this controller is on winning team
   */
  public function GameHasEnded(EndGameFocus:AActor /* = NULL */, bIsWinner:Bool /* = false */) : Void;

}
