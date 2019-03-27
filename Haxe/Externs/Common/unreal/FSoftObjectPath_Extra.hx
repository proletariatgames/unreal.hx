package unreal;

extern class FSoftObjectPath_Extra {
	@:thisConst
	public function IsValid() : Bool;

	/** Returns string representation of reference, in form /package/path.assetname[:subpath] */
	@:thisConst
	public function ToString() : FString;
}
