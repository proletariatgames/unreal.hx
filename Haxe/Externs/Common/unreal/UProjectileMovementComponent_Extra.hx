package unreal;

extern class UProjectileMovementComponent_Extra
{
	function HasStoppedSimulation() : Bool;

	/** Compute the distance we should move in the given time, at a given a velocity. */
	@:thisConst
	private function ComputeMoveDelta(InVelocity:PRef<Const<FVector>>, DeltaTime:Float32) : FVector;
}
