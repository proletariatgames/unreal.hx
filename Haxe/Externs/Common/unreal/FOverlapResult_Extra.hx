package unreal;

extern class FOverlapResult_Extra {
  /** This is the index of the overlapping item.
    For DestructibleComponents, this is the ChunkInfo index.
    For SkeletalMeshComponents this is the Body index or INDEX_NONE for single body */
  var ItemIndex:Int32;

  /** Utility to return the Actor that owns the Component that was hit */
  @:thisConst
  function GetActor() : AActor;

  /** Utility to return the Component that was hit */
  @:thisConst
  function GetComponent() : UPrimitiveComponent;

  @:uname('.ctor') public static function create() : FOverlapResult;
  public function new();
}
