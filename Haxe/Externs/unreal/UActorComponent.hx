package unreal;

@:glueCppIncludes("Components/ActorComponent.h")
@:uname("EComponentCreationMethod")
@:uextern @:class extern enum EComponentCreationMethod {
	/** A component that is part of a native class. */
	Native;
	/** A component that is created from a template defined in the Components section of the Blueprint. */
	SimpleConstructionScript;	
	/**A dynamically created component; either from the UserConstructionScript or from a Add Component node in a Blueprint event graph. */
	UserConstructionScript;
	/** A component added to a single Actor instance via the Component section of the Actor's details panel. */
	Instance;
}

@:glueCppIncludes("Components/ActorComponent.h")
@:uname("ETeleportType")
@:uextern @:class extern enum ETeleportType {
	/** Do not teleport physics body. This means velocity will reflect the movement between initial and final position, and collisions along the way will occur */
	None;
	/** Teleport physics body so that velocity remains the same and no collision occurs */
	TeleportPhysics;
}

@:glueCppIncludes("Components/ActorComponent.h")
@:uextern extern class UActorComponent extends UObject {

  /**
   * Function called every frame on this ActorComponent. Override this function to implement custom logic to be executed every frame.
   * Only executes if the component is registered, and also PrimaryComponentTick.bCanEverTick must be set to true.
   *  
   * @param DeltaTime - The time since the last tick.
   * @param TickType - The kind of tick this is, for example, are we paused, or 'simulating' in the editor
   * @param ThisTickFunction - Internal tick function struct that caused this to run
   */
  public function TickComponent(deltaTime:Float, tickType:ELevelTick, thisTickFunction:unreal.FActorComponentTickFunction) : Void;
}
