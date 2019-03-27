package unreal;

extern class USceneComponent_Extra
{
  /**
   * Initializes desired Attach Parent and SocketName to be attached to when the component is registered.
   * Generally intended to be called from its Owning Actor's constructor and should be preferred over AttachToComponent when
   * a component is not registered.
   * @param  InParent				Parent to attach to.
   * @param  InSocketName			Optional socket to attach to on the parent.
   */
  function SetupAttachment(InParent:USceneComponent, ?InSocketName:FName) : Void;

  /**
   *   Attach this component to another scene component, optionally at a named socket. It is valid to call this on components whether or not they have been Registered.
   *   @param bMaintainWorldTransform	If true, update the relative location/rotation of the component to keep its world position the same
   */
  public function AttachTo(InParent:USceneComponent, InSocketName:FName, AttachType:EAttachLocation, bWeldSimulatedBodies:Bool) : Void;

  /** Calculate the bounds of the component. Default behavior is a bounding box/sphere of zero size. */
  @:thisConst
  public function CalcBounds(LocalToWorld:Const<PRef<FTransform>>) : FBoxSphereBounds;

  public function SetRelativeLocation(NewLocation:FVector, bSweep:Bool /* = false */, OutSweepHitResult:PPtr<FHitResult> /* = null */, Teleport:ETeleportType /* = None */):Void;
  public function SetWorldLocation(NewLocation:FVector, bSweep:Bool /* = false */, OutSweepHitResult:PPtr<FHitResult> /* = null */, Teleport:ETeleportType /* = None */):Void;

  public function GetComponentLocation():FVector;

  @:thisConst
  public function GetComponentTransform():Const<PRef<FTransform>>;

  @:thisConst
  public function GetComponentRotation():FRotator;

  var Bounds:FBoxSphereBounds;
}

