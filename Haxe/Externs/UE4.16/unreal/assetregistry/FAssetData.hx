package unreal.assetregistry;

@:glueCppIncludes("AssetData.h")
@:uextern extern class FAssetData {
  public function GetAsset():UObject;
}
