package unreal.assetregistry;

extern class IAssetRegistry_Extra {
  function GetAssets(Filter:Const<PRef<FARFilter>>, OutAssetData:PRef<TArray<FAssetData>>):Bool;
}
