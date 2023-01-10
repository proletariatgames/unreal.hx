package unreal;

@:hasEquals
extern class FSoftObjectPath_Extra {
	@:thisConst
	public function IsValid() : Bool;

	/** Returns string representation of reference, in form /package/path.assetname[:subpath] */
	@:thisConst
	public function ToString() : FString;

	/**
	 * Attempts to load the asset, this will call LoadObject which can be very slow
	 * @param InLoadContext Optional load context when called from nested load callstack
	 * @return Loaded UObject, or nullptr if the reference is null or the asset fails to load
	 */
	@:thisConst
	public function TryLoad(InLoadContext:PPtr<FUObjectSerializeContext>=null):UObject;

}
