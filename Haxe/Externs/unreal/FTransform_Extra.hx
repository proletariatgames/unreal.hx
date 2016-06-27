package unreal;

extern class FTransform_Extra {

	/**
	 * Constructor with initialization to the identity transform.
	 */
  @:uname('.ctor')
  public static function create() : FTransform;
  @:uname('new')
  public static function createNew() : POwnedPtr<FTransform>;
  @:uname('.ctor')
  public static function copyCreate(InTransform:Const<PRef<FTransform>>) : FTransform;

  /**
   * Constructor with all components initialized, taking a FRotator as the rotation component
   *
   * @param InRotation The value to use for rotation component (after being converted to a quaternion)
   * @param InTranslation The value to use for the translation component
   * @param InScale3D The value to use for the scale component
   */
  @:uname('.ctor')
  public static function createRotatorTranslation(InRotation:Const<PRef<FRotator>>, InTranslation:Const<PRef<FVector>>) : FTransform;
  @:uname('new')
  public static function createNewRotatorTranslation(InRotation:Const<PRef<FRotator>>, InTranslation:Const<PRef<FVector>>) : POwnedPtr<FTransform>;

  @:thisConst
  public function InverseTransformVectorNoScale(v:Const<PRef<FVector>>) : FVector;

  @:thisConst
  public function GetLocation() : FVector;
}
