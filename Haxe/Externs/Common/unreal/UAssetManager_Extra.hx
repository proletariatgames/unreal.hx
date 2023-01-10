package unreal;

import unreal.assetregistry.*;

extern class UAssetManager_Extra {
	public static function Get() : PRef<UAssetManager>;

	public static function GetStreamableManager():PRef<FStreamableManager>;

	/** Gets the FSoftObjectPath for a primary asset type and name, returns invalid if not found */
	public function GetPrimaryAssetPath(AssetID:PRef<FPrimaryAssetId>) : FSoftObjectPath;

	/** Gets the in-memory UObject for a primary asset id, returning nullptr if it's not in memory.
		Will return blueprint class for blueprint assets. This works even if the asset wasn't loaded explicitly */
	public function GetPrimaryAssetObject(AssetID:PRef<FPrimaryAssetId>) : UObject;

	/** Gets list of all loaded objects for a primary asset type, returns true if any were found. Will return blueprint
		class for blueprint assets. This works even if the asset wasn't loaded explicitly */
	public function GetPrimaryAssetObjectList(PrimaryAssetType:FPrimaryAssetType , ObjectList:PRef<TArray<UObject>>) : Bool;

	@:thisConst public function GetPrimaryAssetIdForPath(ObjectPath:Const<PRef<FSoftObjectPath>>):FPrimaryAssetId;

	/** Gets list of all FAssetData for a primary asset type, returns true if any were found */
	public function GetPrimaryAssetDataList(PrimaryAssetType:FPrimaryAssetType, PrimaryAssetList:PRef<TArray<unreal.assetregistry.FAssetData>>) : Bool;

	/** Sees if the passed in object is a registered primary asset, if so return it. Returns invalid Identifier if not found */
	@:thisConst public function GetPrimaryAssetIdForObject(Object:UObject) : FPrimaryAssetId;

	/** Returns the primary asset Id for the given FAssetData, only works if in directory */
	@:thisConst public function GetPrimaryAssetIdForData(AssetData:Const<PRef<FAssetData>>) : FPrimaryAssetId;

	@:typeName public function GetPrimaryAssetObjectClass<T : UObject>(PrimaryAssetId:Const<PRef<FPrimaryAssetId>>) : TSubclassOf<T>;

	/** Gets list of all primary asset types infos */
	@:thisConst public function GetPrimaryAssetTypeInfoList(AssetTypeInfoList:PRef<TArray<FPrimaryAssetTypeInfo>>) : Void;

	/** Gets list of all FPrimaryAssetId for a primary asset type, returns true if any were found */
	@:thisConst
	public function GetPrimaryAssetIdList(PrimaryAssetType:FPrimaryAssetType, PrimaryAssetIdList:PRef<TArray<FPrimaryAssetId>>) : Bool;

	/**
	 * Loads a list of Primary Assets. This will start an async load of those assets, calling callback on completion.
	 * These assets will stay in memory until explicitly unloaded.
	 * You can wait on the returned streamable request or poll as needed.
	 * If there is no work to do, returned handle will be null and delegate will get called before function returns.
	 *
	 * @param AssetsToLoad		List of primary assets to load
	 * @param LoadBundles		List of bundles to load for those assets
	 * @param DelegateToCall	Delegate that will be called on completion, may be called before function returns if assets are already loaded
	 * @param Priority			Async loading priority for this request
	 * @return					Streamable Handle that can be used to poll or wait. You do not need to keep this handle to stop the assets from being unloaded
	 */
	public function LoadPrimaryAssets(AssetsToLoad:PRef<Const<TArray<FPrimaryAssetId>>>, LoadBundles:PRef<Const<TArray<FName>>>, DelegateToCall:FStreamableDelegate) : TSharedPtr<FStreamableHandle>;

	/** Single asset wrapper */
	public function LoadPrimaryAsset(AssetToLoad:PRef<Const<FPrimaryAssetId>>, LoadBundles:PRef<Const<TArray<FName>>>, DelegateToCall:FStreamableDelegate) : TSharedPtr<FStreamableHandle>;

	/** Loads all assets of a given type, useful for cooking */
	public function LoadPrimaryAssetsWithType(PrimaryAssetType:FPrimaryAssetType, LoadBundles:PRef<Const<TArray<FName>>>, DelegateToCall:FStreamableDelegate) : TSharedPtr<FStreamableHandle>;

	/**
	 * Preloads data for a set of assets in a specific bundle state, and returns a handle you must keep active.
	 * These assets are not officially Loaded, so Unload/ChangeBundleState will not affect them and if you release the handle
	 * without otherwise loading the assets they will be freed.
	 *
	 * @param AssetsToLoad		List of primary assets to load
	 * @param LoadBundles		List of bundles to load for those assets
	 * @param bLoadRecursive	If true, this will call RecursivelyExpandBundleData and recurse into sub bundles of other primary assets loaded by a bundle reference
	 * @param DelegateToCall	Delegate that will be called on completion, may be called before function returns if assets are already loaded
	 * @param Priority			Async loading priority for this request
	 * @return					Streamable Handle that must be stored to keep the preloaded assets from being freed
	 */
	public function PreloadPrimaryAssets(AssetsToLoad:PRef<Const<TArray<FPrimaryAssetId>>>, LoadBundles:PRef<Const<TArray<FName>>>, bLoadRecursive:Bool, DelegateToCall:FStreamableDelegate, ?Priority:Int32 = 0) : TSharedPtr<FStreamableHandle>;

	/**
		Returns a valid bundle entry (`FAssetBundleEntry#IsValid`) if the asset id points to an asset that is loaded with the provided bundle.
		Otherwise returns an invalid entry.
	**/
	@:thisConst
	public function GetAssetBundleEntry(BundleScope:PRef<Const<FPrimaryAssetId>>, BundleName:FName):FAssetBundleEntry;

	@:thisConst
	public function GetAssetBundleEntries(BundleScope:PRef<Const<FPrimaryAssetId>>, OutEntries:PRef<TArray<FAssetBundleEntry>>):Bool;

}
