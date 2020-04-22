package unreal;

extern class UPrimitiveComponent_Extra {
  /** Event called when a component is 'damaged', allowing for component class specific behaviour */
	function ReceiveComponentDamage(DamageAmount:Float32, DamageEvent:Const<PRef<FDamageEvent>>, EventInstigator:AController, DamageCauser:AActor) : Void;

	/**
	 *	Force all bodies in this component to sleep.
	 */
	function PutAllRigidBodiesToSleep():Void;

	/**
	 *	Returns if a single body is currently awake and simulating.
	 *	@param	BoneName	If a SkeletalMeshComponent, name of body to return wakeful state from. 'None' indicates root body.
	 */
	function RigidBodyIsAwake(BoneName:FName):Bool;

	/** Recreate the physics state right way. */
	function RecreatePhysicsState():Void;

	/**
	 *  Test the collision of the supplied shape at the supplied location, and determine if it overlaps this component.
	 *
	 *  @param  Pos             Location to place PrimComp geometry at
	 *	@param	Rot				Rotation of PrimComp geometry
	 *  @param  CollisionShape 	Shape of collision of PrimComp geometry
	 *  @return true if PrimComp overlaps this component at the specified location/rotation
	 */
	public function OverlapComponent(Pos:PRef<Const<FVector>>, Rot:PRef<Const<FQuat>>, CollisionShape:PRef<Const<FCollisionShape>>) : Bool;

	/**
	 * Return a CollisionShape that most closely matches this primitive.
	 */
	@:thisConst
	public function GetCollisionShape(Inflation:Float32 = 0.0) : FCollisionShape;

	/**
	*   Welds this component to another scene component, optionally at a named socket. Component is automatically attached if not already
	*	Welding allows the child physics object to become physically connected to its parent. This is useful for creating compound rigid bodies with correct mass distribution.
	*   @param InParent the component to be physically attached to
	*   @param InSocketName optional socket to attach component to
	*/
	public function WeldTo(InParent:USceneComponent, InSocketName:FName) : Void;
}
