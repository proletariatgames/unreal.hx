package unreal;

extern class AActor_Extra {
  public function Tick(DeltaSeconds:Float32) : Void;

  public function Reset() : Void;

  /**
    Get the owner of this Actor, user primarily for network replication
    @return Actor that owns this Actor
   **/
  @:thisConst
  public function GetOwner() : AActor;

  /**
    See if this actor contains the supplied tag
   **/
  @:thisConst
  public function ActorHasTag(Tag:PStruct<FName>) : Bool;

  @:ufunction(BlueprintCallable, Category="Utilities|Transformation")
  public function SetActorScale3D(NewScale3D:FVector): Void;
}
