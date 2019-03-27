package unreal;

extern class FRandomStream_Extra {
  public function new(seed:Int32);

  @:uname(".ctor")
  public static function create() : FRandomStream;

  @:uname(".ctor")
  public static function createWithSeed(seed:Int32) : FRandomStream;

	/**
	 * Initializes this random stream with the specified seed value.
	 *
	 * @param InSeed The seed value.
	 */
  public function Initialize(seed:Int32) : Void;

	/**
	 * Resets this random stream to the initial seed value.
	 */
  @:thisConst
  public function Reset() : Void;

  @:thisConst
  public function GetInitialSeed() : Int32;

	/**
	 * Gets the current seed.
	 *
	 * @return Current seed.
	 */
  @:thisConst
  public function GetCurrentSeed() : Int32;

	/**
	 * Generates a new random seed.
	 */
  public function GenerateNewSeed() : Void;

	/**
	 * Returns a random number between 0 and 1.
	 *
	 * @return Random number.
	 */
  @:thisConst
  public function GetFraction() : Float32;

	/**
	 * Returns a random number between 0 and MAXUINT.
	 *
	 * @return Random number.
	 */
  @:thisConst
  public function GetUnsignedInt() : Int32;

	/**
	 * Returns a random vector of unit size.
	 *
	 * @return Random unit vector.
	 */
  @:thisConst
  public function GetUnitVector() : FVector;

  	/**
	 * Mirrors the random number API in FMath
	 *
	 * @return Random number.
	 */
  @:thisConst
  public function FRand() : Float32;

  /**
	 * Helper function for rand implementations.
	 *
	 * @return A random number >= Min and <= Max
	 */
  @:thisConst
  public function RandRange(Min:Int32, Max:Int32) : Int32;

  	/**
	 * Helper function for rand implementations.
	 *
	 * @return A random number >= Min and <= Max
	 */
  @:thisConst
  public function FRandRange( InMin:Float32, InMax:Float32 ) : Float32;

	/**
	 * Returns a random vector of unit size.
	 *
	 * @return Random unit vector.
	 */
  @:thisConst
  public function VRand() : FVector;

  	/**
	 * Returns a random unit vector, uniformly distributed, within the specified cone.
	 *
	 * @param Dir The center direction of the cone
	 * @param ConeHalfAngleRad Half-angle of cone, in radians.
	 * @return Normalized vector within the specified cone.
	 */
  @:thisConst
  public function VRandCone(Dir:Const<PRef<FVector>>, ConeHalfAngleRad:Float32) : FVector;

	/**
	 * Returns a random unit vector, uniformly distributed, within the specified cone.
	 *
	 * @param Dir The center direction of the cone
	 * @param HorizontalConeHalfAngleRad Horizontal half-angle of cone, in radians.
	 * @param VerticalConeHalfAngleRad Vertical half-angle of cone, in radians.
	 * @return Normalized vector within the specified cone.
	 */
  @:thisConst @:uname('VRandCone')
	public function VRandConeDualAngle(Dir:Const<PRef<FVector>>, HorizontalConeHalfAngleRad:Float32, VerticalConeHalfAngleRad:Float32) : FVector;
}