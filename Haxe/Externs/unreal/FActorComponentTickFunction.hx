package unreal;

/** 
* Tick function that calls UActorComponent::ConditionalTick
**/
@:glueCppIncludes("Engine.h")
@:uextern extern class FActorComponentTickFunction extends FTickFunction {
  /**  AActor  component that is the target of this tick **/
  public var Target:UActorComponent;
}