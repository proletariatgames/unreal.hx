package unreal;

@:glueCppIncludes("Engine/EngineTypes.h")
@:uextern extern class FDamageEvent {

	/** Optional DamageType for this event.  If nullptr, UDamageType will be assumed. */
	@:uproperty()
	public var DamageTypeClass : TSubclassOf<UDamageType>;

	@thisConst
	public function GetTypeID() : Int32;

	@thisConst
	public function IsOfType(InID : Int32) : Bool;

	public static var ClassID(get,never) : Int32;
}
