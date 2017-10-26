package unreal;

extern class FMath_Extra {
  public static function VInterpTo(Current : unreal.FVector, Target : unreal.FVector, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FVector;

  public static function VInterpConstantTo(Current : unreal.FVector, Target : unreal.FVector, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FVector;

  public static function Vector2DInterpTo(Current : unreal.FVector2D, Target : unreal.FVector2D, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FVector2D;

  public static function RInterpTo(Current : unreal.FRotator, Target : unreal.FRotator, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.FRotator;

  public static function FInterpTo(Current : unreal.Float32, Target : unreal.Float32, DeltaTime : unreal.Float32, InterpSpeed : unreal.Float32) : unreal.Float32;

	/** Returns a random point within the passed in bounding box */
  public static function RandPointInBox(Box : Const<PRef<unreal.FBox>>) : unreal.FVector;

  /** Util to generate a random number in a range. Overloaded to distinguish from int32 version, where passing a float is typically a mistake. */
  public static function RandRange(Min:Float32, Max:Float32) : Float32;

  /** Helper function for rand implementations. Returns a random number >= Min and <= Max */
  @:uname("RandRange")
  public static function RandRangeInt(Min:Int32, Max:Int32) : Int32;

	/** Util to generate a random boolean. */
  public static function RandBool() : Bool;

  /** Return a uniformly distributed random unit length vector = point on the unit sphere surface. */
  public static function VRand() : unreal.FVector;

	/**
	 * Returns a random unit vector, uniformly distributed, within the specified cone
	 * ConeHalfAngleRad is the half-angle of cone, in radians.  Returns a normalized vector. 
	 */
  public static function VRandCone(Dir:Const<PRef<unreal.FVector>>, ConeHalfAngleRad:Float32) : FVector;

	/** 
	 * This is a version of VRandCone that handles "squished" cones, i.e. with different angle limits in the Y and Z axes.
	 * Assumes world Y and Z, although this could be extended to handle arbitrary rotations.
	 */
  @:uname("VRandCone")
  public static function VRandConeHorizVert(Dir:Const<PRef<unreal.FVector>>, HorizontalConeHalfAngleRad:Float32, VerticalConeHalfAngleRad:Float32) : FVector;

 	/** Returns a random integer between 0 and RAND_MAX, inclusive */
  public static function Rand() : Int32;

	/** Seeds global random number functions Rand() and FRand() */
  public static function RandInit(Seed:Int32) : Void;

	/** Returns a random float between 0 and 1, inclusive. */
  public static function FRand() : Float32;

	/** Seeds future calls to SRand() */
  public static function SRandInit(Seed:Int32) : Void;

	/** Returns the current seed for SRand(). */
	public static function GetRandSeed() : Int32;

	/** Returns a seeded random float in the range [0,1), using the seed from SRandInit(). */
  public static function SRand() : Float32;
}
