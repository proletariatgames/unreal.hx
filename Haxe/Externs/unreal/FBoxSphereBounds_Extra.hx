package unreal;

extern class FBoxSphereBounds_Extra
{
	/**
	 * Creates and initializes a new instance.
	 *
	 * @param EForceInit Force Init Enum.
	 */
  @:uname('new')
  public static function createForceInit(Force:EForceInit) : POwnedPtr<FBoxSphereBounds>;

	/**
	 * Creates and initializes a new instance from the specified parameters.
	 *
	 * @param InOrigin origin of the bounding box and sphere.
	 * @param InBoxExtent half size of box.
	 * @param InSphereRadius radius of the sphere.
	 */
  @:uname('new')
  public static function createWithParams(InOrigin:Const<PRef<FVector>>, InBoxExtent:Const<PRef<FVector>>, InSphereRadius:Float32) : POwnedPtr<FBoxSphereBounds>;

	/**
	 * Creates and initializes a new instance the given Box.
	 *
	 * The sphere radius is taken from the extent of the box.
	 *
	 * @param Box The bounding box.
	 */
  @:uname('new')
  public static function createWithBox(Box:Const<PRef<FBox>>) : POwnedPtr<FBoxSphereBounds>;


	/**
	 * Creates and initializes a new instance for the given sphere.
	 */
  @:uname('new')
  public static function createWithSphere(Sphere:Const<PRef<FSphere>>) : POwnedPtr<FBoxSphereBounds>;

  @:thisConst
  public function GetBox() : FBox;

  @:thisConst
  public function GetSphere() : FSphere;
}
