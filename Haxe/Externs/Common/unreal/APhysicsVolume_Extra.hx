package unreal;

extern class APhysicsVolume_Extra {

	// Called when actor enters a volume
	function ActorEnteredVolume(Other:AActor) : Void;

	// Called when actor leaves a volume, Other can be NULL
	function ActorLeavingVolume(Other:AActor) : Void;
}