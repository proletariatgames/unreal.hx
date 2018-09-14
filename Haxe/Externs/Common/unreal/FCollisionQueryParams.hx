/* Hand created since it's not a USTRUCT */

package unreal;

@:glueCppIncludes("CollisionQueryParams.h")

/** Structure that defines parameters passed into collision function */
@:uextern extern class FCollisionQueryParams {
  public function new(bInTraceComplex:Bool);
  /** Tag used to provide extra information or filtering for debugging of the trace (e.g. Collision Analyzer) */
  public var TraceTag : FName;

  /** Tag used to indicate an owner for this trace */
  public var OwnerTag : FName;

  /** Whether we should perform the trace in the asynchronous scene.  Default is false. */
  public var bTraceAsyncScene : Bool;

  /** Whether we should trace against complex collision */
  public var bTraceComplex : Bool;

  /** Whether we want to find out initial overlap or not. If true, it will return if this was initial overlap. */
  public var bFindInitialOverlaps : Bool;

  /** Whether we want to return the triangle face index for complex static mesh traces */
  public var bReturnFaceIndex : Bool;

  /** Only fill in the PhysMaterial field of  */
  public var bReturnPhysicalMaterial : Bool;

  // Constructors
  @:uname('.ctor') public static function create(bInTraceComplex:Bool) : FCollisionQueryParams;
  @:uname('new') public static function createNew(bInTraceComplex:Bool) : POwnedPtr<FCollisionQueryParams>;

  @:uname('.ctor') public static function createWithParams(InTraceTag:FName, bInTraceComplex:Bool, InIgnoreActor:Const<AActor>) : FCollisionQueryParams;
  @:uname('new') public static function createNewWithParams(InTraceTag:FName, bInTraceComplex:Bool, InIgnoreActor:Const<AActor>) : POwnedPtr<FCollisionQueryParams>;

  /** Add an actor for this trace to ignore */
  public function AddIgnoredActor(InIgnoreActor:Const<AActor>) : Void;

	/** Add a component for this trace to ignore */
	public function AddIgnoredComponent(InIgnoreComponent:Const<UPrimitiveComponent>) : Void;

}
