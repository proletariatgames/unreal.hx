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
}
