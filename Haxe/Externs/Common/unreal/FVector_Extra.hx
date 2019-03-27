package unreal;

@:hasCopy
extern class FVector_Extra {
  public function new(x:Float32, y:Float32, z:Float32);

  @:uname('.ctor') public static function createWithValues(x:Float32, y:Float32, z:Float32):FVector;
  @:uname('new') public static function createNewWithValues(x:Float32, y:Float32, z:Float32):POwnedPtr<FVector>;

  @:uname('.ctor') public static function createForceInit(e:EForceInit):FVector;
  @:uname('new') public static function createNewForceInit(e:EForceInit):POwnedPtr<FVector>;

  /**
   * Gets a normalized copy of the 2D components of the vector, checking it is safe to do so. Z is set to zero.
   * Returns zero vector if vector length is too small to normalize.
   *
   * @param Tolerance Minimum squared vector length.
   * @return Normalized copy if safe, otherwise returns zero vector.
   */
  @:thisConst
  public function GetSafeNormal2D() : FVector;

  /**
   * Gets a normalized copy of the vector, checking it is safe to do so based on the length.
   * Returns zero vector if vector length is too small to safely normalize.
   *
   * @param Tolerance Minimum squared vector length.
   * @return A normalized copy if safe, (0,0,0) otherwise.
   */
  @:thisConst
  public function GetSafeNormal() : FVector;

  @:thisConst
  public function Size() : Float32;

  @:thisConst
  public function SizeSquared() : Float32;

  @:thisConst
  public function Size2D() : Float32;

  @:thisConst
  public function SizeSquared2D() : Float32;

  @:thisConst
  public function Rotation() : FRotator;

  /**
   * Rotates around Axis (assumes Axis.Size() == 1).
   *
   * @param Angle Angle to rotate (in degrees).
   * @param Axis Axis to rotate around.
   * @return Rotated Vector.
   */
  @:thisConst
  public function RotateAngleAxis(AngleDeg:Float32, Axis:Const<PRef<FVector>>) : FVector;

  public var X:Float32;
  public var Y:Float32;
  public var Z:Float32;

  @:expr public static var ZeroVector (get,never) : Const<FVector>;

  @:expr public static var OneVector (get,never) : Const<FVector>;

  @:expr public static var UpVector (get,never) : Const<FVector>;

  @:expr public static var ForwardVector (get,never) : Const<FVector>;

  @:expr public static var RightVector (get,never) : Const<FVector>;

  @:expr({
    return createWithValues(0,0,0);
  }) private static function get_ZeroVector() : Const<FVector>;

  @:expr({
    return createWithValues(1,1,1);
  }) private static function get_OneVector() : Const<FVector>;

  @:expr({
    return createWithValues(0,0,1);
  }) private static function get_UpVector() : Const<FVector>;

  @:expr({
    return createWithValues(1,0,0);
  }) private static function get_ForwardVector() : Const<FVector>;

  @:expr({
    return createWithValues(0,1,0);
  }) private static function get_RightVector() : Const<FVector>;

  /**
   * Initialize this Vector based on an FString . The String is expected to contain X=, Y=, Z=.
   * The FVector will be bogus when InitFromString returns false.
   * @param InSourceString	FString containing the vector values.
   * @return true if the X,Y,Z values were read successfully; false otherwise.
   */
  public function InitFromString(InSourceString:Const<PRef<FString>>) : Bool;

  public function HeadingAngle() : Float32;

  public static function Dist(V1:Const<PRef<FVector>>, V2:Const<PRef<FVector>>):Float32;
  public static function DistSquared(V1:Const<PRef<FVector>>, V2:Const<PRef<FVector>>):Float32;

  public static function DotProduct(A:Const<PRef<FVector>>, B:Const<PRef<FVector>>):Float32;

  public static function CrossProduct(A:Const<PRef<FVector>>, B:Const<PRef<FVector>>):Const<FVector>;

  @:op(A+B)
  @:expr(return createWithValues(X + b.X, Y + b.Y, Z + b.Z))
  public function _add(b:FVector):FVector;

  @:op(A+=B)
  @:expr(return FVectorUtils.addeq(cast this, b))
  public function _addeq(b:FVector):FVector;

  @:op(A*B)
  @:commutative
  @:expr(return createWithValues(X * b.X, Y * b.Y, Z * b.Z))
  public function _mul(b:FVector):FVector;

  @:op(A*B)
  @:commutative
  @:expr(return createWithValues(X * b, Y * b, Z * b))
  public function _mulScalar(b:Float):FVector;

  @:op(A*=B)
  @:expr(return FVectorUtils.muleq(cast this, b))
  public function _mulScalareq(b:Float):FVector;

  @:op(A-B)
  @:expr(return createWithValues(X - b.X, Y - b.Y, Z - b.Z))
  public function _sub(b:FVector):FVector;

  @:op(A-=B)
  @:expr(return FVectorUtils.subeq(cast this, b))
  public function _subeq(b:FVector):FVector;

  @:op(A==B)
  @:expr(return X == b.X && Y == b.Y && Z == b.Z)
  public function _eq(b:FVector):Bool;

  public function IsNearlyZero():Bool;

  public function IsZero():Bool;

  public function Equals(b:FVector, Tolerance:Float32):Bool;

  @:expr(return 'FVector($X,$Y,$Z)')
  public function toString():String;

  public function ToOrientationRotator():Const<FRotator>;

	/**
	 * Create an orthonormal basis from a basis with at least two orthogonal vectors.
	 * It may change the directions of the X and Y axes to make the basis orthogonal,
	 * but it won't change the direction of the Z axis.
	 * All axes will be normalized.
	 *
	 * @param XAxis The input basis' XAxis, and upon return the orthonormal basis' XAxis.
	 * @param YAxis The input basis' YAxis, and upon return the orthonormal basis' YAxis.
	 * @param ZAxis The input basis' ZAxis, and upon return the orthonormal basis' ZAxis.
	 */
	public static function CreateOrthonormalBasis(XAxis:PRef<FVector>,YAxis:PRef<FVector>,ZAxis:PRef<FVector>) : Void;

  public function ToDirectionAndLength(OutDir:PRef<FVector>, OutLength:Ref<Float32>):Void;

  /** Create a copy of this vector, with its magnitude clamped between Min and Max. */
  @:thisConst
  public function GetClampedToSize(Min:Float32, Max:Float32) : FVector;

  /** Create a copy of this vector, with the 2D magnitude clamped between Min and Max. Z is unchanged. */
  @:thisConst
  public function GetClampedToSize2D(Min:Float32, Max:Float32) : FVector;

  /** Create a copy of this vector, with its maximum magnitude clamped to MaxSize. */
  @:thisConst
  public function GetClampedToMaxSize(MaxSize:Float32) : FVector;

  /** Create a copy of this vector, with the maximum 2D magnitude clamped to MaxSize. Z is unchanged. */
  @:thisConst
  public function GetClampedToMaxSize2D(MaxSize:Float32) : FVector;
}
