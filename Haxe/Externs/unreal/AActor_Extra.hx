package unreal;

extern class AActor_Extra {
  public function PreInitializeComponents() : Void;

  public function Tick(DeltaSeconds:Float32) : Void;

  public function Reset() : Void;

  /** Event when play begins for this actor. */
  public function BeginPlay() : Void;

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
  public function GetWorldSettings() : AWorldSettings;

	/** Get the timer instance from the actors world */
	@:thisConst
  public function GetWorldTimerManager() : PRef<FTimerManager>;

  @:thisConst public function GetActorLocation() : FVector;

  public function NotifyActorBeginOverlap(OtherActor:AActor) : Void;

  public static function GetDebugName(actor:Const<AActor>) : FString;
}
