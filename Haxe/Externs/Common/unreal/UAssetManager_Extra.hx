package unreal;

import unreal.assetregistry.*;

extern class UAssetManager_Extra {
  public static function Get() : PRef<UAssetManager>;
	public function GetPrimaryAssetPath(AssetID:PRef<FPrimaryAssetId>) : FSoftObjectPath;
	public function GetPrimaryAssetObject(AssetID:PRef<FPrimaryAssetId>) : UObject;
	public function GetPrimaryAssetObjectList(PrimaryAssetType:FPrimaryAssetType , ObjectList:PRef<TArray<UObject>>) : Bool;
	public function GetPrimaryAssetIdList(PrimaryAssetType:FPrimaryAssetType, PrimaryAssetIdList:PRef<TArray<FPrimaryAssetId>>) : Bool;
	public function GetPrimaryAssetDataList(PrimaryAssetType:FPrimaryAssetType, PrimaryAssetList:PRef<TArray<unreal.assetregistry.FAssetData>>) : Bool;
	@:thisConst public function GetPrimaryAssetIdForObject(Object:UObject) : FPrimaryAssetId;
	@:thisConst public function GetPrimaryAssetIdForData(AssetData:Const<PRef<FAssetData>>) : FPrimaryAssetId;
	@:typeName public function GetPrimaryAssetObjectClass<T : UObject>(PrimaryAssetId:Const<PRef<FPrimaryAssetId>>) : TSubclassOf<T>;
	@:thisConst public function GetPrimaryAssetTypeInfoList(AssetTypeInfoList:PRef<TArray<FPrimaryAssetTypeInfo>>) : Void;

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
}
