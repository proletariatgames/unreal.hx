package unreal;

extern class AActor extends UObject
{
  @:UPROPERTY public var bHidden:Bool;
  @:UPROPERTY private var bEditable:Bool;
  // public var PrimaryActorTick:FActorTickFunction;

  // public function ActorHasTag(tag:FName):Bool;
}
