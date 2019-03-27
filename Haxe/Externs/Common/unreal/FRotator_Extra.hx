package unreal;

@:hasCopy
extern class FRotator_Extra {

  @:uname('.ctor') public static function createForceInit(e:EForceInit):FRotator;
  @:uname('new') public static function createNewForceInit(e:EForceInit):POwnedPtr<FRotator>;

  @:uname('.ctor') public static function createWithSingleValue(inF:Float32):FRotator;
  @:uname('new') public static function createNewWithSingleValue(inF:Float32):POwnedPtr<FRotator>;

  @:uname('.ctor') public static function createWithValues(inPitch:Float32, inYaw:Float32, inRoll:Float32):FRotator;
  @:uname('new') public static function createNewWithValues(inPitch:Float32, inYaw:Float32, inRoll:Float32):POwnedPtr<FRotator>;

  @:uname('.ctor') public static function createFromQuat(quat:Const<PRef<FQuat>>):FRotator;
  @:uname('new') public static function createNewFromQuat(quat:Const<PRef<FQuat>>):POwnedPtr<FRotator>;

  public var Pitch:Float32;
  public var Yaw:Float32;
  public var Roll:Float32;

	/**
	 * Convert a rotation into a unit vector facing in its direction.
	 *
	 * @return Rotation as a unit direction vector.
	 */
  @:thisConst
  public function Vector() : FVector;

	/**
	 * Checks whether rotator is nearly zero within specified tolerance, when treated as an orientation.
	 * This means that FRotator(0, 0, 360) is "zero", because it is the same final orientation as the zero rotator.
	 *
	 * @param Tolerance Error Tolerance.
	 * @return true if rotator is nearly zero, within specified tolerance, otherwise false.
	 */
  @:thisConst
  public function IsNearlyZero(Tolerance:Float32=1e-4) : Bool;

	/**
	 * Checks whether this has exactly zero rotation, when treated as an orientation.
	 * This means that FRotator(0, 0, 360) is "zero", because it is the same final orientation as the zero rotator.
	 *
	 * @return true if this has exactly zero rotation, otherwise false.
	 */
  @:thisConst
  public function IsZero() : Bool;

	/**
	 * Checks whether two rotators are equal within specified tolerance, when treated as an orientation.
	 * This means that FRotator(0, 0, 360).Equals(FRotator(0,0,0)) is true, because they represent the same final orientation.
	 *
	 * @param R The other rotator.
	 * @param Tolerance Error Tolerance.
	 * @return true if two rotators are equal, within specified tolerance, otherwise false.
	 */
  @:thisConst
  public function Equals(R:Const<PRef<FRotator>>, Tolerance:Float32=1e-4) : Bool;

	/**
	 * Adds to each component of the rotator.
	 *
	 * @param DeltaPitch Change in pitch. (+/-)
	 * @param DeltaYaw Change in yaw. (+/-)
	 * @param DeltaRoll Change in roll. (+/-)
	 * @return Copy of rotator after addition.
	 */
  public function Add(DeltaPitch:Float32, DeltaYaw:Float32, DeltaRoll:Float32) : FRotator;

	/**
	 * Returns the inverse of the rotator.
	 */
  @:thisConst
  public function GetInverse() : FRotator;

	/**
	 * Get the rotation, snapped to specified degree segments.
	 *
	 * @param RotGrid A Rotator specifying how to snap each component.
	 * @return Snapped version of rotation.
	 */
  @:thisConst
  public function GridSnap(RotGrid:Const<PRef<FRotator>>) : FRotator;

	/**
	 * Get Rotation as a quaternion.
	 *
	 * @return Rotation as a quaternion.
	 */
  @:thisConst
  public function Quaternion() : FQuat;

	/**
	 * Convert a Rotator into floating-point Euler angles (in degrees). Rotator now stored in degrees.
	 *
	 * @return Rotation as a Euler angle vector.
	 */
  @:thisConst
  public function Euler() : FVector;

	/**
	 * Rotate a vector rotated by this rotator.
	 *
	 * @param V The vector to rotate.
	 * @return The rotated vector.
	 */
  @:thisConst
  public function RotateVector(V:Const<PRef<FVector>>) : FVector;

	/**
	 * Returns the vector rotated by the inverse of this rotator.
	 *
	 * @param V The vector to rotate.
	 * @return The rotated vector.
	 */
  @:thisConst
  public function UnrotateVector(V:Const<PRef<FVector>>) : FVector;

	/**
	 * Gets the rotation values so they fall within the range [0,360]
	 *
	 * @return Clamped version of rotator.
	 */
  @:thisConst
  public function Clamp() : FRotator;

	public static function ClampAxis(Angle:Float32) : Float32;

	/**
	 * Create a copy of this rotator and normalize, removes all winding and creates the "shortest route" rotation.
	 *
	 * @return Normalized copy of this rotator
	 */
  @:thisConst
  public function GetNormalized() : FRotator;

	/**
	 * Create a copy of this rotator and denormalize, clamping each axis to 0 - 360.
	 *
	 * @return Denormalized copy of this rotator
	 */
  @:thisConst
  public function GetDenormalized() : FRotator;

	/** Get a specific component of the vector, given a specific axis by enum */
  @:thisConst
  public function GetComponentForAxis(Axis:EAxis) : Float32;

  /** Set a specified componet of the vector, given a specific axis by enum */
  public function SetComponentForAxis(Axis:EAxis, Component:Float32) : Void;

	/**
	 * In-place normalize, removes all winding and creates the "shortest route" rotation.
	 */
  public function Normalize() : Void;

	/**
	 * Decompose this Rotator into a Winding part (multiples of 360) and a Remainder part.
	 * Remainder will always be in [-180, 180] range.
	 *
	 * @param Winding[Out] the Winding part of this Rotator
	 * @param Remainder[Out] the Remainder
	 */
  @:thisConst
  public function GetWindingAndRemainder(Winding:PRef<FRotator>, Remainder:PRef<FRotator>) : Void;

  	/**
	 * Get a textual representation of the vector.
	 *
	 * @return Text describing the vector.
	 */
  @:thisConst
  public function ToString() : FString;

	/** Get a short textural representation of this vector, for compact readable logging. */
  @:thisConst
  public function ToCompactString() : FString;

	/**
	 * Initialize this Rotator based on an FString. The String is expected to contain P=, Y=, R=.
	 * The FRotator will be bogus when InitFromString returns false.
	 *
	 * @param InSourceString	FString containing the rotator values.
	 * @return true if the P,Y,R values were read successfully; false otherwise.
	 */
  public function InitFromString(InSourceString:Const<PRef<FString>>) : Bool;

	/**
	 * Utility to check if there are any non-finite values (NaN or Inf) in this Rotator.
	 *
	 * @return true if there are any non-finite values in this Rotator, otherwise false.
	 */
  @:thisConst
  public function ContainsNaN() : Bool;

	/**
	 * Convert a vector of floating-point Euler angles (in degrees) into a Rotator. Rotator now stored in degrees
	 *
	 * @param Euler Euler angle vector.
	 * @return A rotator from a Euler angle.
	 */
  public static function MakeFromEuler(Euler:Const<PRef<FVector>>) : FRotator;

	/**
	 * Compresses a floating point angle into a byte.
	 *
	 * @param Angle The angle to compress.
	 * @return The angle as a byte.
	 */
	public static function CompressAxisToByte( Angle:Float32 ) : UInt8;

	/**
	 * Decompress a word into a floating point angle.
	 *
	 * @param Angle The word angle.
	 * @return The decompressed angle.
	 */
	public static function DecompressAxisFromByte( Angle:UInt8 ) : Float32;

	/**
	 * Compress a floating point angle into a word.
	 *
	 * @param Angle The angle to compress.
	 * @return The decompressed angle.
	 */
	public static function CompressAxisToShort( Angle:Float32 ) : UInt16;

	/**
	 * Decompress a short into a floating point angle.
	 *
	 * @param Angle The word angle.
	 * @return The decompressed angle.
	 */
	public static function DecompressAxisFromShort( Angle : UInt16 ) : Float32;

  @:expr static var ZeroRotator(get, never):FRotator;

  @:expr({
    return createWithValues(0,0,0);
  }) private static function get_ZeroRotator() : FRotator;

  @:op(A+B)
  @:expr(return createWithValues(Pitch + b.Pitch, Yaw + b.Yaw, Roll + b.Roll))
  public function _add(b:FRotator):FRotator;

  @:op(A*B)
  @:expr(return createWithValues(Pitch*b, Yaw*b, Roll*b))
  public function _mul(b:Float32):FRotator;
}
