package unreal;

extern class UPrimitiveComponent_Extra {
  /** Event called when a component is 'damaged', allowing for component class specific behaviour */
	function ReceiveComponentDamage(DamageAmount:Float32, DamageEvent:Const<PRef<FDamageEvent>>, EventInstigator:AController, DamageCauser:AActor) : Void;

  #if proletariat
  // Proletariat-specific Unreal extentsion
  function SetRenderToSecondaryCustomDepth(val:Bool) : Void;
  #end

	/**
	 *	Event called when the underlying physics objects is put to sleep
	 */
  var OnComponentSleep:FComponentSleepSignature;

	/**
	 *	Event called when something starts to overlaps this component, for example a player walking into a trigger.
	 *	For events when objects have a blocking collision, for example a player hitting a wall, see 'Hit' events.
	 *
	 *	@note Both this component and the other one must have bGenerateOverlapEvents set to true to generate overlap events.
	 *	@note When receiving an overlap from another object's movement, the directions of 'Hit.Normal' and 'Hit.ImpactNormal'
	 *	will be adjusted to indicate force from the other object against this object.
	 */
	var OnComponentBeginOverlap:FComponentBeginOverlapSignature;

	/**
	 *	Force all bodies in this component to sleep.
	 */
	function PutAllRigidBodiesToSleep():Void;

	/**
	 *	Returns if a single body is currently awake and simulating.
	 *	@param	BoneName	If a SkeletalMeshComponent, name of body to return wakeful state from. 'None' indicates root body.
	 */
	function RigidBodyIsAwake(BoneName:FName):Bool;

	/**
	 *	Returns if any body in this component is currently awake and simulating.
	 */
	function IsAnyRigidBodyAwake():Bool;

	/** Recreate the physics state right way. */
	function RecreatePhysicsState():Void;
}