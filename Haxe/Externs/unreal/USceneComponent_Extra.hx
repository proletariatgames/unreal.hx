package unreal;

extern class USceneComponent_Extra
{
  /**
   *   Attach this component to another scene component, optionally at a named socket. It is valid to call this on components whether or not they have been Registered.
   *   @param bMaintainWorldTransform	If true, update the relative location/rotation of the component to keep its world position the same
   */
  public function AttachTo(InParent:USceneComponent, InSocketName:FName, AttachType:EAttachLocation, bWeldSimulatedBodies:Bool) : Void;

  /** Calculate the bounds of the component. Default behavior is a bounding box/sphere of zero size. */
  @:thisConst
  public function CalcBounds(LocalToWorld:Const<PRef<FTransform>>) : FBoxSphereBounds;

  public function SetRelativeLocation(NewLocation:FVector, bSweep:Bool /* = false */, OutSweepHitResult:PPtr<FHitResult> /* = null */, Teleport:ETeleportType /* = None */):Void;

  public function GetComponentLocation():FVector;

  var Bounds:FBoxSphereBounds;
}

