package unreal;

@:hasCopy
extern class FPlane_Extra {
  public function new(InBase:FVector, InNormal:FVector);

	/**
	 * Constructor.
	 *
	 * @param InBase Base point in plane.
	 * @param InNormal Plane Normal Vector.
	 */
  @:uname('.ctor') public static function createWithValues(InBase:FVector, InNormal:FVector):FPlane;
  @:uname('new') public static function createNewWithValues(InBase:FVector, InNormal:FVector):POwnedPtr<FPlane>;

  @:uname('.ctor') public static function createForceInit(e:EForceInit):FPlane;
  @:uname('new') public static function createNewForceInit(e:EForceInit):POwnedPtr<FPlane>;

	public var W:Float32;

	/**
	 * Calculates distance between plane and a point.
	 *
	 * @param P The other point.
	 * @return The distance from the plane to the point. 0: Point is on the plane. >0: Point is in front of the plane. <0: Point is behind the plane.
	 */
	@:thisConst
	public function PlaneDot(P:Const<PRef<FVector>>) : Float32;
}
