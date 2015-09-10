package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class AActor extends UObject
{
  @:UPROPERTY public var bHidden:Bool;
  // TODO: allow private vars
  // @:UPROPERTY private var bEditable:Bool;
  // public var PrimaryActorTick:FActorTickFunction;

  // public function ActorHasTag(tag:FName):Bool;
}
