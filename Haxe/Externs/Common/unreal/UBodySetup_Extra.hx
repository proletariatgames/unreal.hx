package unreal;

extern class UBodySetup_Extra {
  /**
   * Rescales simple collision geometry.  Note you must recreate physics meshes after this
   *
   * @param BuildScale	The scale to apply to the geometry
  */
  function RescaleSimpleCollision( BuildScale:FVector ) : Void;

  /** Create Physics meshes (ConvexMeshes, TriMesh & TriMeshNegX) from cooked data */
  function CreatePhysicsMeshes() : Void;

  /** Release Physics meshes (ConvexMeshes, TriMesh & TriMeshNegX) */
  function ClearPhysicsMeshes() : Void;
}