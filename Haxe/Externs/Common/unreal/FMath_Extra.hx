package unreal;

extern class FMath_Extra {

	@:expr(3.4e+38)
	public static var BIG_NUMBER(default, null):Float;

	@:expr(1.e-4)
	public static var KINDA_SMALL_NUMBER(default, null):Float;

	@:expr(1.e-8)
	public static var SMALL_NUMBER(default, null):Float;

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

/**
	 * Converts radians to degrees.
	 * @param RadVal Value in radians.
	 * @return Value in degrees.
	 */
	public static function RadiansToDegrees(RadVal:Float32) : Float32;

	/**
	 * Converts degrees to radians.
	 * @param DegVal Value in degrees.
	 * @return Value in radians.
	 */
	public static function DegreesToRadians(DegVal:Float32) : Float32;

	/**
	 * Clamps an arbitrary angle to be between the given angles.  Will clamp to nearest boundary.
	 *
	 * @param MinAngleDegrees "from" angle that defines the beginning of the range of valid angles (sweeping clockwise)
	 * @param MaxAngleDegrees "to" angle that defines the end of the range of valid angles
	 * @return Returns clamped angle in the range -180..180.
	 */
	public static function ClampAngle(AngleDegrees:Float32, MinAngleDegrees:Float32, MaxAngleDegrees:Float32) : Float32;

	/** Find the smallest angle between two headings (in degrees) */
	public static function FindDeltaAngleDegrees(A1:Float32, A2:Float32) : Float32;

	/** Find the smallest angle between two headings (in radians) */
	public static function FindDeltaAngleRadians(A1:Float32, A2:Float32) : Float32;

	/** Given a heading which may be outside the +/- PI range, 'unwind' it back into that range. */
	public static function UnwindRadians(A:Float32) : Float32;

		/** Utility to ensure angle is between +/- 180 degrees by unwinding. */
	public static function UnwindDegrees(A:Float32) : Float32;

		/**
	 * Given two angles in degrees, 'wind' the rotation in Angle1 so that it avoids >180 degree flips.
	 * Good for winding rotations previously expressed as quaternions into a euler-angle representation.
	 * @param	Angle0 The first angle that we wind relative to.
	 * @param	Angle1 The second angle that we may wind relative to the first.
	 */
	public static function WindRelativeAnglesDegrees(InAngle0:Float32, InOutAngle0:PRef<Float32>) : Void;

	/** Returns a new rotation component value
	 *
	 * @param InCurrent is the current rotation value
	 * @param InDesired is the desired rotation value
	 * @param InDeltaRate is the rotation amount to apply
	 *
	 * @return a new rotation component value
	 */
	public static function FixedTurn(InCurrent:Float32, InDesired:Float32, InDeltaRate:Float32) : Float32;

	/** Calculates the percentage along a line from MinValue to MaxValue that Value is. */
	public static function GetRangePct(MinValue:Float32, MaxValue:Float32, Value:Float32) : Float32;

	/** Performs a linear interpolation between two values, Alpha ranges from 0-1 */
	public static function Lerp(A:Float32, B:Float32, Alpha:Float32) : Float32;
	/** Performs a linear interpolation between two values, Alpha ranges from 0-1 */
	@:uname('Lerp')
	public static function LerpRotator(A:Const<PRef<FRotator>>, B:Const<PRef<FRotator>>, Alpha:Float32) : FRotator;
	/** Performs a linear interpolation between two values, Alpha ranges from 0-1 */
	@:uname('Lerp')
	public static function LerpQuat(A:Const<PRef<FQuat>>, B:Const<PRef<FQuat>>, Alpha:Float32) : FQuat;

	/** Interpolate between A and B, applying an ease in function.  Exp controls the degree of the curve. */
	public static function InterpEaseIn(A:Float32, B:Float32, Alpha:Float32, Exp:Float32) : Float32;

	/** Interpolate between A and B, applying an ease out function.  Exp controls the degree of the curve. */
	public static function InterpEaseOut(A:Float32, B:Float32, Alpha:Float32, Exp:Float32) : Float32;

	/** Interpolate between A and B, applying an ease in/out function.  Exp controls the degree of the curve. */
	public static function InterpEaseInOut(A:Float32, B:Float32, Alpha:Float32, Exp:Float32) : Float32;

	/** Interpolation between A and B, applying a step function. */
	public static function InterpStep(A:Float32, B:Float32, Alpha:Float32, Steps:Int32) : Float32;

	/**
	 * Returns the floating-point remainder of X / Y
	 * Warning: Always returns remainder toward 0, not toward the smaller multiple of Y.
	 * So for example Fmod(2.8f, 2) gives .8f as you would expect, however, Fmod(-2.8f, 2) gives -.8f, NOT 1.2f
	 * Use Floor instead when snapping positions that can be negative to a grid
	 */
	public static function Fmod(X:Float32, Y:Float32) : Float32;

	/**
	 * Checks if two floating point numbers are nearly equal.
	 * @param A First number to compare
	 * @param B Second number to compare
	 * @param ErrorTolerance Maximum allowed difference for considering them as 'nearly equal'
	 * @return true if A and B are nearly equal
	 */
	public static function IsNearlyEqual(A:Float32, B:Float32, ErrorTolerance:Float32 = SMALL_NUMBER) : Bool;

	/**
	 * Given a direction vector and a surface normal, returns the vector reflected across the surface normal.
	 * Produces a result like shining a laser at a mirror!
	 *
	 * @param Direction Direction vector the ray is coming from.
	 * @param SurfaceNormal A normal of the surface the ray should be reflected on.
	 *
	 * @returns Reflected vector.
	 */
	public static function GetReflectionVector(Direction:Const<PRef<FVector>>, SurfaceNormal:Const<PRef<FVector>>) : FVector;

	/** Clamps X to be between Min and Max, inclusive */
	public static function Clamp(X:Float32, Min:Float32, Max:Float32) : Float32;
}
