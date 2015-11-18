package unreal;

extern class AController_Extra {
  public function PawnPendingDestroy(inPawn:APawn) : Void;

  @:thisConst
  public function GetCharacter() : ACharacter;

  @:thisConst public function GetPawn() : unreal.APawn;

  public function ChangeState(NewState:FName) : Void;

	public function GameHasEnded(EndGameFocus:AActor, bIsWinner:Bool) : Void;
}
