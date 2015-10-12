package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class UAnimInstance extends UObject {

    /** Returns the owning actor of this AnimInstance */
  @:ufunction(BlueprintCallable, Category = "Animation")
  public function GetOwningActor() : AActor;
}