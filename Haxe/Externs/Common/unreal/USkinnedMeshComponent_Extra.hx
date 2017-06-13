package unreal;

extern class USkinnedMeshComponent_Extra {
  /**
   * Return PhysicsAsset for this SkeletalMeshComponent
   * It will return SkeletalMesh's PhysicsAsset unless PhysicsAssetOverride is set for this component
   *
   * @return : PhysicsAsset that's used by this component
   */
  @:thisConst
  function GetPhysicsAsset() : UPhysicsAsset;
}