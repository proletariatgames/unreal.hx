package unreal;

extern class UMovementComponent_Extra {
	/**
	 * Flags that control the behavior of calls to MoveComponent() on our UpdatedComponent.
	 * @see EMoveComponentFlags
	 */
  public var MoveComponentFlags:EMoveComponentFlags;

  /**
    Initialize collision params appropriately based on our collision settings. Use this before any Line, Overlap, or Sweep tests.
   **/
  function InitCollisionParams(OutParams:PRef<FCollisionQueryParams>, OutResponseParam:PRef<FCollisionResponseParams>):Void;
}
