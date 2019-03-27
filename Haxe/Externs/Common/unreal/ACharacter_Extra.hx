package unreal;

extern class ACharacter_Extra {
  public function GetCharacterMovement() : UCharacterMovementComponent;

  /** Returns CapsuleComponent subobject **/
  @:thisConst
  public function GetCapsuleComponent() : UCapsuleComponent;

  public function GetMesh() : USkeletalMeshComponent;

  /** Apply momentum caused by damage. */
  public function ApplyDamageMomentum(DamageTaken:Float32, DamageEvent:Const<PRef<FDamageEvent>>, PawnInstigator:APawn, DamageCauser:AActor) : Void;

  public function CheckJumpInput(deltaSeconds:Float32) : Void;

#if (UE_VER <= 4.19)
  public function ClearJumpInput() : Void;
#else
  public function ClearJumpInput(DeltaTime:Float32) : Void;
#end

  /**
   * Called upon landing when falling, to perform actions based on the Hit result. Triggers the OnLanded event.
   * Note that movement mode is still "Falling" during this event. Current Velocity value is the velocity at the time of landing.
   * Consider OnMovementModeChanged() as well, as that can be used once the movement mode changes to the new mode (most likely Walking).
   *
   * @param Hit Result describing the landing that resulted in a valid landing spot.
   * @see OnMovementModeChanged()
   */
  public function Landed(Hit:Const<PRef<FHitResult>>) : Void;

  @:thisConst
  private function CanJumpInternal_Implementation() : Bool;

  /** Name of the CharacterMovement component. Use this name if you want to use a different class (with ObjectInitializer.SetDefaultSubobjectClass). */
  public static var CharacterMovementComponentName : FName;

  public function MoveBlockedBy(Impact:Const<PRef<FHitResult>>):Void;

	/** @return true if this character is currently able to crouch (and is not currently crouched) */
  public function CanCrouch() : Bool;

/** Set the Pawn's Player State. Keeps bi-directional reference of Pawn to Player State and back in sync. */
	public function SetPlayerState(NewPlayerState:APlayerState) : Void;

  /** If Pawn is possessed by a player, returns its Player State.  Needed for network play as controllers are not replicated to clients. */
  @:thisConst
	public function GetPlayerState() : APlayerState;
}
