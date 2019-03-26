package unreal.assetregistry;

extern class FAssetData_Extra {
  @:thisConst
  public function GetAsset():UObject;
  @:thisConst
  public function GetFullName() : FString;
  @:thisConst
  public function GetPrimaryAssetId() : FPrimaryAssetId;
}
