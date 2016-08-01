package unreal;

extern class AController_Extra {
  public function PawnPendingDestroy(inPawn:APawn) : Void;

  @:thisConst
  public function GetCharacter() : ACharacter;

  @:thisConst
  public function GetPawn() : APawn;

  public function ChangeState(newState:FName) : Void;
  @:thisConst
  public function IsInState(state:FName) : Bool;
  @:thisConst
  public function GetStateName() : FName;

  /**
   * Called from game mode upon end of the game, used to transition to proper state.
   * @param EndGameFocus Actor to set as the view target on end game
   * @param bIsWinner true if this controller is on winning team
   */
  public function GameHasEnded(EndGameFocus:AActor /* = NULL */, bIsWinner:Bool /* = false */) : Void;

	/**
	 * Returns Player's Point of View
	 * For the AI this means the Pawn's 'Eyes' ViewPoint
	 * For a Human player, this means the Camera's ViewPoint
	 *
	 * @output	out_Location, view location of player
	 * @output	out_rotation, view rotation of player
	*/
  @:thisConst
  function GetPlayerViewPoint(out_Location:PRef<FVector>, out_Rotation:PRef<FRotator>) : Void;

}
