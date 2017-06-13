package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class FOverlapResult {
  /** Actor that the check hit. */
  var Actor : TWeakObjectPtr<AActor>;
  /** PrimitiveComponent that the check hit. */
  var Component : TWeakObjectPtr<UPrimitiveComponent>;
	/** This is the index of the overlapping item.
		For DestructibleComponents, this is the ChunkInfo index.
		For SkeletalMeshComponents this is the Body index or INDEX_NONE for single body */
  var ItemIndex:Int32;
  /** Indicates if this hit was requesting a block - if false, was requesting a touch instead */
  var bBlockingHit:Bool;

	/** Utility to return the Actor that owns the Component that was hit */
  @:thisConst
	function GetActor() : AActor;

 	/** Utility to return the Component that was hit */
  @:thisConst
  function GetComponent() : UPrimitiveComponent;

  @:uname('.ctor') public static function create() : FOverlapResult;
  public function new();
}
