package unreal;

extern class AActor_Extra {
  /** Dormancy setting for actor to take itself off of the replication list without being destroyed on clients. */
  public var NetDormancy:ENetDormancy;

  public function Tick(DeltaSeconds:Float32) : Void;

  public function Reset() : Void;

  /** Event when play begins for this actor. */
  public function BeginPlay() : Void;
  /** Overridable function called whenever this actor is being removed from a level */
  public function EndPlay(Reason:EEndPlayReason) : Void;

	/** Puts actor in dormant networking state */
	public function SetNetDormancy(NewDormancy:ENetDormancy) : Void;

  /**
   * Destroy this actor. Returns true the actor is destroyed or already marked for destruction, false if indestructible.
   * Destruction is latent. It occurs at the end of the tick.
   * @param bNetForce       [opt] Ignored unless called during play.  Default is false.
   * @param bShouldModifyLevel    [opt] If true, Modify() the level before removing the actor.  Default is true.
   * returns  true if destroyed or already marked for destruction, false if indestructible.
   */
  public function Destroy(bNetForce:Bool, bShouldModifyLevel:Bool) : Void;

  /** Called once this actor has been deleted */
  public function Destroyed() : Void;

  /** Apply damage to this actor.
   * @see https://www.unrealengine.com/blog/damage-in-ue4
   * @param DamageAmount    How much damage to apply
   * @param DamageEvent   Data package that fully describes the damage received.
   * @param EventInstigator The Controller responsible for the damage.
   * @param DamageCauser    The Actor that directly caused the damage (e.g. the projectile that exploded, the rock that landed on you)
   * @return          The amount of damage actually applied.
   */
  public function TakeDamage(DamageAmount:Float32, DamageEvent:Const<PRef<FDamageEvent>>,EventInstigator:AController, DamageCauser:AActor) : Float32;

  /** Returns this actor's root component. */
  @:thisConst
  public function GetRootComponent() : USceneComponent;

  @:thisConst
  public function GetActorLocation() : FVector;

  public function SetActorLocation(vec:Const<PRef<FVector>>, bSweep:Bool, outSweepResult:PPtr<FHitResult>) : Bool;

  @:thisConst
  public function GetActorRotation() : FRotator;

  @:thisConst
  public function GetActorQuat() : FQuat;

  /** Called immediately before gameplay begins. */
  public function PreInitializeComponents() : Void;

  // Allow actors to initialize themselves on the C++ side
  public function PostInitializeComponents() : Void;
  public function GetWorldSettings() : AWorldSettings;

	/** Get the timer instance from the actors world */
	@:thisConst
  public function GetWorldTimerManager() : PRef<FTimerManager>;

	/**
	 *	Event when this actor overlaps another actor, for example a player walking into a trigger.
	 *	For events when objects have a blocking collision, for example a player hitting a wall, see 'Hit' events.
	 *	@note Components on both this and the other Actor must have bGenerateOverlapEvents set to true to generate overlap events.
	 */
  public function NotifyActorBeginOverlap(OtherActor:AActor) : Void;

	/**
	 *	Event when an actor no longer overlaps another actor, and they have separated.
	 *	@note Components on both this and the other Actor must have bGenerateOverlapEvents set to true to generate overlap events.
	 */
	public function NotifyActorEndOverlap(OtherActor:AActor) : Void;

  public function TornOff() : Void;

	/**
	 * Called when an instance of this class is placed (in editor) or spawned.
	 * @param	Transform			The transform the actor was constructed at.
	 */
	public function OnConstruction(Transform:Const<PRef<FTransform>>) : Void;


  // TODO glue when we can properly handle const UDamageType& extern.
  /** called when the actor falls out of the world 'safely' (below KillZ and such) */
  // public function FellOutOfWorld(dmgType:Const<PRef<UDamageType>>) : Void;

  /**
   * Event when this actor bumps into a blocking object, or blocks another actor that bumps into it.
   * This could happen due to things like Character movement, using Set Location with 'sweep' enabled, or physics simulation.
   * For events when objects overlap (e.g. walking into a trigger) see the 'Overlap' event.
   *
   * @note For collisions during physics simulation to generate hit events, 'Simulation Generates Hit Events' must be enabled.
   * @note When receiving a hit from another object's movement (bSelfMoved is false), the directions of 'Hit.Normal' and 'Hit.ImpactNormal'
   * will be adjusted to indicate force from the other object against this object.
   */
  public function NotifyHit(MyComp:UPrimitiveComponent,
    Other:AActor,
    OtherComp:UPrimitiveComponent,
    bSelfMoved:Bool,
    HitLocation:FVector,
    HitNormal:FVector,
    NormalImpulse:FVector,
    Hit:Const<PRef<FHitResult>>) : Void;

  public function GetNetMode() : ENetMode;

  /** Get the local-to-world transform of the RootComponent. Identical to GetTransform(). */
  @:thisConst
  public function ActorToWorld() : FTransform;

  public static function GetDebugName(actor:Const<AActor>) : FString;

  @:thisConst
  public function ShouldTickIfViewportsOnly() : Bool;

  #if WITH_EDITOR
  public function PostEditMove(bFinished:Bool) : Void;
	public function EditorApplyScale(DeltaScale:Const<PRef<FVector>>, PivotLocation:PPtr<Const<FVector>>, bAltDown:Bool, bShiftDown:Bool, bCtrlDown:Bool) : Void;
  @:thisConst
  public function GetReferencedContentObjects(Objects:PRef<TArray<UObject>>) : Bool;
  #end

  function TeleportTo(destLocation:Const<PRef<FVector>>, destRotation:Const<PRef<FRotator>>, bIsATest:Bool /* = false */, bNoCheck:Bool /* = false */):Bool;

	/** Returns true if this actor has begun the destruction process.
	 *  This is set to true in UWorld::DestroyActor, after the network connection has been closed but before any other shutdown has been performed.
	 *	@return true if this actor has begun destruction, or if this actor has been destroyed already.
	 **/
  @:thisConst
  function IsPendingKillPending() : Bool;

	/* Called when this actor becomes the given PlayerController's ViewTarget. Triggers the Blueprint event K2_OnBecomeViewTarget. */
	function BecomeViewTarget( PC:APlayerController ) : Void;

	/* Called when this actor is no longer the given PlayerController's ViewTarget. Also triggers the Blueprint event K2_OnEndViewTarget. */
	function EndViewTarget( PC:APlayerController ) : Void;

  /** Removes a component from the OwnedComponents array of the Actor.
   *  In general this should not need to be called directly by anything other than UActorComponent functions
   */
  public function RemoveOwnedComponent(Component:UActorComponent) : Void;

}
