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
