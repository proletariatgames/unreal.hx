package unreal.assetregistry;

extern class FAssetBundleEntry_Extra
{

	/** Returns true if this represents a real entry */
	@:thisConst public function IsValid():Bool;

	/** Returns true if it has a valid scope, if false is a global entry or in the process of being created */
	@:thisConst public function IsScoped():Bool;

}
