package unreal;

extern class UMovementComponent_Extra {
  /**
    Initialize collision params appropriately based on our collision settings. Use this before any Line, Overlap, or Sweep tests.
   **/
  function InitCollisionParams(OutParams:PRef<FCollisionQueryParams>, OutResponseParam:PRef<FCollisionResponseParams>):Void;
}
