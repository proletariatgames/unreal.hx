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

  public function CanJumpInternal_Implementation() : Bool;

  /** Name of the CharacterMovement component. Use this name if you want to use a different class (with ObjectInitializer.SetDefaultSubobjectClass). */
  public static var CharacterMovementComponentName : FName;
}
