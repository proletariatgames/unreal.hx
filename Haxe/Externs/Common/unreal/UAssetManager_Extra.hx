package unreal;

extern class UAssetManager_Extra {
  public static function Get() : PRef<UAssetManager>;
	public function GetPrimaryAssetObjectList(PrimaryAssetType:FPrimaryAssetType , ObjectList:PRef<TArray<UObject>>) : Bool;
	public function GetPrimaryAssetIdList(PrimaryAssetType:FPrimaryAssetType, PrimaryAssetIdList:PRef<TArray<FPrimaryAssetId>>) : Bool;
}
