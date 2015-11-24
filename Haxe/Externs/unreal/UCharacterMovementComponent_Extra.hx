package unreal;
extern class UCharacterMovementComponent_Extra {

  /**
   * Perform jump. Called by Character when a jump has been detected because Character->bPressedJump was true. Checks CanJump().
   * Note that you should usually trigger a jump through Character::Jump() instead.
   * @param bReplayingMoves: true if this is being done as part of replaying moves on a locally controlled client after a server correction.
   * @return  True if the jump was triggered successfully.
   */
  public function DoJump(bReplayingMoves:Bool) : Bool;
}
