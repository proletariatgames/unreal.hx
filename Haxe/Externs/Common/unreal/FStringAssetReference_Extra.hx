package unreal;

#if (UE_VER < 4.19)
@:glueCppIncludes('Misc/StringAssetReference.h')
@:hasEquals @:hasCopy
extern class FStringAssetReference_Extra {
  @:uname('.ctor') public static function create(pathString:FString):FStringAssetReference;
  @:uname('new') public static function createNew(pathString:FString):POwnedPtr<FStringAssetReference>;

  /**
   * Attempts to load the asset.
   * @return Loaded UObject, or null if the asset fails to load, or if the reference is not valid.
   */
  @:thisConst function TryLoad():UObject;

  /**
   * Attempts to find a currently loaded object that matches this object ID
   * @return Found UObject, or NULL if not currently loaded
   */
  @:thisConst function ResolveObject():UObject;

  /**
   * Check if this could possibly refer to a real object, or was initialized to NULL
   */
  @:thisConst function IsValid():Bool;

  function ToString():FString;

}
#end // (UE_VER < 4.19)
