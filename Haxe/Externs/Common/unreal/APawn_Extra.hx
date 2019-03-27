package unreal;

extern class APawn_Extra {
  public function Restart() : Void;

  /** Tell client that the Pawn is begin restarted. Calls Restart(). */
  public function PawnClientRestart() : Void;

	/** @return	Pawn's eye location */
  @:thisConst
  public function GetPawnViewLocation() : FVector;

  /**
   * Get the view rotation of the Pawn (direction they are looking, normally Controller->ControlRotation).
   * @return The view rotation of the Pawn.
   */
  @:thisConst
  public function GetViewRotation() : FRotator;

  /** Allows a Pawn to set up custom input bindings. Called upon possession by a PlayerController, using the InputComponent created by CreatePlayerInputComponent(). */
  private function SetupPlayerInputComponent(inInputComponent:UInputComponent) : Void;

  public function PossessedBy(newController:AController) : Void;
  public function UnPossessed() : Void;
}
