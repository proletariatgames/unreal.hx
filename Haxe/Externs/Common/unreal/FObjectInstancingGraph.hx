package unreal;

@:glueCppIncludes("UObject/Class.h")
@:uextern @:noCopy @:noEquals extern class FObjectInstancingGraph {
	/**
	 * Sets the DestinationRoot for this instancing graph.
	 *
	 * @param	DestinationSubobjectRoot	the top-level object that is being created
	 * @param	InSourceRoot	Archetype of DestinationSubobjectRoot
	 */
	public function SetDestinationRoot( DestinationSubobjectRoot : UObject, InSourceRoot : UObject ) : Void;

	/**
	 * Finds the destination object instance corresponding to the specified source object.
	 *
	 * @param	SourceObject			the object to find the corresponding instance for
	 */
	public function GetDestinationObject(SourceObject: UObject) : UObject;

	/**
	 * Adds a partially built object instance to the map(s) of source objects to their instances.
	 * @param	ObjectInstance  Object that was just allocated, but has not been constructed yet
	 * @param	InArchetype     Archetype of ObjectInstance
	 */
	public function AddNewObject(ObjectInstance:UObject, InArchetype:UObject) : Void;

	/**
	 * Adds an object instance to the map of source objects to their instances.  If there is already a mapping for this object, it will be replaced
	 * and the value corresponding to ObjectInstance's archetype will now point to ObjectInstance.
	 *
	 * @param	ObjectInstance  the object that should be added as the corresopnding instance for ObjectSource
	 * @param	InArchetype     Archetype of ObjectInstance
	 */
	public function AddNewInstance(ObjectInstance : UObject, InArchetype : UObject) : Void;

	/**
	 * Retrieves a list of objects that have the specified Outer
	 *
	 * @param	SearchOuter		the object to retrieve object instances for
	 * @param	out_Components	receives the list of objects contained by SearchOuter
	 */
	public function RetrieveObjectInstances( SearchOuter : UObject, out_Objects : PRef<TArray<UObject>> ) : Void;

	/**
	 * Enables / disables component instancing.
	 */
	public function EnableSubobjectInstancing(bEnabled:Bool) : Void;

	/**
	 * Returns whether component instancing is enabled
	 */
	@:thisConst
	public function IsSubobjectInstancingEnabled() : Bool;

	/**
	 * Sets whether DestinationRoot is currently being loaded from disk.
	 */
	public function SetLoadingObject( bIsLoading:Bool ) : Void;
}