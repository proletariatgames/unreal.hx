package unreal.assetregistry;

@:noCopy
@:noEquals
@:glueCppIncludes("AssetRegistryModule.h")
@:uextern extern class FAssetRegistryModule {
  function Get():Const<PRef<IAssetRegistry>>;
}
