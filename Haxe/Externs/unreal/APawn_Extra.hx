package unreal;

extern class APawn_Extra {
  public function Restart() : Void;

  /** Tell client that the Pawn is begin restarted. Calls Restart(). */
  public function PawnClientRestart() : Void;
}
