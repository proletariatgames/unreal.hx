package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class ACharacter extends APawn {

  public function GetCharacterMovement() : UCharacterMovementComponent;
}
