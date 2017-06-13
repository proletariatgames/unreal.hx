package unreal;
extern class UCharacterMovementComponent_Extra {

  /**
   * Perform jump. Called by Character when a jump has been detected because Character->bPressedJump was true. Checks CanJump().
   * Note that you should usually trigger a jump through Character::Jump() instead.
   * @param bReplayingMoves: true if this is being done as part of replaying moves on a locally controlled client after a server correction.
   * @return  True if the jump was triggered successfully.
   */
  public function DoJump(bReplayingMoves:Bool) : Bool;


  /**
   * Checks if new capsule size fits (no encroachment), and call CharacterOwner->OnStartCrouch() if successful.
   * In general you should set bWantsToCrouch instead to have the crouch persist during movement, or just use the crouch functions on the owning Character.
   * @param	bClientSimulation	true when called when bIsCrouched is replicated to non owned clients, to update collision cylinder and offset.
   */
  function Crouch(bClientSimulation:Bool) : Void;

  /**
    * Checks if default capsule size fits (no encroachment), and trigger OnEndCrouch() on the owner if successful.
   * @param	bClientSimulation	true when called when bIsCrouched is replicated to non owned clients, to update collision cylinder and offset.
   */
  function UnCrouch(bClientSimulation:Bool) : Void;

  /** @return true if the character is allowed to crouch in the current state. By default it is allowed when walking or falling, if CanEverCrouch() is true. */
  @:thisConst
  function CanCrouchInCurrentState() : Bool;

  /**
    MovementMode string
   **/
  function GetMovementName():FString;
  function StartFalling(Iterations:Int, remainingTime:Float32, timeTick:Float32, Delta:Const<PRef<FVector>>, subLoc:  Const<PRef<FVector>>):Void;

  /**
    Movement update functions should only be called through StartNewPhysics()
   **/
  private function PhysWalking(deltaTime:Float32, Iterations:Int32):Void;

  @:thisConst private function ScaleInputAcceleration(InputAcceleration:Const<PRef<FVector>>):FVector;
}
