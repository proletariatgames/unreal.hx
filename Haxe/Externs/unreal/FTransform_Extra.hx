package unreal;

extern class FTransform_Extra {

	/**
	 * Constructor with initialization to the identity transform.
	 */
  @:uname('new')
  public static function create() : POwnedPtr<FTransform>;

  /**
   * Constructor with all components initialized, taking a FRotator as the rotation component
   *
   * @param InRotation The value to use for rotation component (after being converted to a quaternion)
   * @param InTranslation The value to use for the translation component
   * @param InScale3D The value to use for the scale component
   */
  @:uname('new')
  public static function createRotatorTranslation(InRotation:Const<PRef<FRotator>>, InTranslation:Const<PRef<FVector>>) : POwnedPtr<FTransform>;

  @:thisConst
  public function InverseTransformVectorNoScale(v:Const<PRef<FVector>>) : FVector;

  @:thisConst
  public function GetLocation() : FVector;
}
