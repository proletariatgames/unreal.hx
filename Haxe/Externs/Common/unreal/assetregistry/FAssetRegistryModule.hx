package unreal.assetregistry;

@:noCopy
@:noEquals
@:glueCppIncludes("AssetRegistryModule.h")
@:uextern extern class FAssetRegistryModule {
  @:thisConst
  function Get():PRef<IAssetRegistry>;
}