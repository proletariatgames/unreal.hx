package unreal;

import unreal.FActorTickFunction;

@:glueCppIncludes("Engine.h")
@:uextern extern class AActor extends UObject
{
  @:UPROPERTY public var bHidden:Bool;
  // TODO: allow private vars
  // @:UPROPERTY private var bEditable:Bool;
  public var PrimaryActorTick:PStruct<FActorTickFunction>;

  public function Tick(DeltaSeconds:Float32) : Void;

  public function Reset() : Void;

	/** Describes how much control the local machine has over the actor. */
	@:uproperty(Replicated)
	public var Role : ENetRole;

  /**
   * Get the owner of this Actor, used primarily for network replication.
   * @return Actor that owns this Actor
   */
  @:ufunction(BlueprintCallable, Category=Actor)
  @:thisConst
  public function GetOwner() : AActor;

  /** See if this actor contains the supplied tag */
  @:ufunction(BlueprintCallable, Category="Utilities")
  @:thisConst
  public function ActorHasTag(Tag:PStruct<FName>) : Bool;
}
