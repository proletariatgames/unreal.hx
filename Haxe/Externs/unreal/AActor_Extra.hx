package unreal;

extern class AActor_Extra {
  public function PreInitializeComponents() : Void;

  public function Tick(DeltaSeconds:Float32) : Void;

  public function Reset() : Void;

  /** Event when play begins for this actor. */
  public function BeginPlay() : Void;

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

  @:thisConst
  public function GetActorRotation() : FRotator;

  /** Called immediately before gameplay begins. */
  public function PreInitializeComponents() : Void;

  // Allow actors to initialize themselves on the C++ side
  public function PostInitializeComponents() : Void;
  public function GetWorldSettings() : AWorldSettings;

	/** Get the timer instance from the actors world */
	@:thisConst
  public function GetWorldTimerManager() : PRef<FTimerManager>;
}
