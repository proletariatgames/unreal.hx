package unreal.assetregistry;

@:noCopy
@:noEquals
@:glueCppIncludes("IAssetRegistry.h")
@:uextern extern class IAssetRegistry {
  function GetAssets(Filter:Const<PRef<FARFilter>>, OutAssetData:PRef<TArray<FAssetData>>):Bool;
}
