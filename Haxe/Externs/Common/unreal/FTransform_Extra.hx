package unreal;

extern class FTransform_Extra {
  public function new();

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
  @:thisconst
  public function Rotator() : FRotator;

  public static function Multiply(out:PPtr<FTransform>, a:Const<PPtr<FTransform>>, b:Const<PPtr<FTransform>>):Void;

	/** Copy translation from another FTransform. */
	function CopyTranslation(Other:Const<PRef<FTransform>>) : Void;
	/** Copy scale from another FTransform. */
	function CopyScale3D(Other:Const<PRef<FTransform>>) : Void;
	/** Copy rotation from another FTransform. */
	function CopyRotation(Other:Const<PRef<FTransform>>) : Void;

  /**
	 * Sets the translation component
	 * @param NewTranslation The new value for the translation component
	 */
	function SetTranslation(NewTranslation:Const<PRef<FVector>>) : Void;
	/**
	 * Sets the rotation component
	 * @param NewRotation The new value for the rotation component
	 */
	function SetRotation(NewRotation:Const<PRef<FQuat>>) : Void;
	/**
	 * Sets the Scale3D component
	 * @param NewScale3D The new value for the Scale3D component
	 */
	function SetScale3D(NewScale3D:Const<PRef<FVector>>) : Void;
}
