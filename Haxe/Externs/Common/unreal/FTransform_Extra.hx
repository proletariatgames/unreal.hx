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

  /**
    createRotatorTranslation alias
   **/
  @:expr(return createRotatorTranslation(InRotation, InTranslation))
  public static function createWithValues(InRotation:FRotator, InTranslation:FVector) : FTransform;

  /**
    createNewRotatorTranslation alias
   **/
  @:expr(return createNewRotatorTranslation(InRotation, InTranslation))
  public static function createNewWithValues(InRotation:FRotator, InTranslation:FVector) : POwnedPtr<FTransform>;

  @:thisConst
  public function TransformVector(V:PRef<Const<FVector>>) : FVector;
  @:thisConst
  public function TransformVectorNoScale(V:PRef<Const<FVector>>) : FVector;

  @:thisConst
  public function InverseTransformVector(v:Const<PRef<FVector>>) : FVector;
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
  /**
	 * Returns the Scale3D component
	 *
	 * @return The Scale3D component
	 */
	function GetScale3D() : FVector;

  /**
	 * Returns the rotation component
	 *
	 * @return The rotation component
	 */
  function GetRotation() : Const<FQuat>;

  /**
	 * Concatenates another rotation to this transformation
	 * @param DeltaRotation The rotation to concatenate in the following fashion: Rotation = Rotation * DeltaRotation
	 */
  function ConcatenateRotation(DeltaRotation:Const<PRef<FQuat>>) : Void;

  /**
	 * Adjusts the translation component of this transformation
	 * @param DeltaTranslation The translation to add in the following fashion: Translation += DeltaTranslation
	 */
	function AddToTranslation(DeltaTranlation:Const<PRef<FVector>>) : Void;

  /**
	 * Scales the Scale3D component by a new factor
	 * @param Scale3DMultiplier The value to multiply Scale3D with
	 */
	function MultiplyScale3D(Scale3DMultiplier:Const<PRef<FVector>>) : Void;
}
