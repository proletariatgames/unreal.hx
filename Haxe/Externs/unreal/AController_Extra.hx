package unreal;

extern class AController_Extra {
  public function PawnPendingDestroy(inPawn:APawn) : Void;

  @:thisConst
  public function GetCharacter() : ACharacter;

  @:thisConst
  public function GetPawn() : APawn;
}
