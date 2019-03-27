package unreal;

extern class FQuat_Extra {
  @:uname('.ctor') public static function create() : FQuat;
  @:uname('new') public static function createNew() : POwnedPtr<FQuat>;
  @:uname('.ctor') public static function createFromRotator(rotator:Const<PRef<FRotator>>) : FQuat;
  @:uname('new') public static function createNewFromRotator(rotator:Const<PRef<FRotator>>) : POwnedPtr<FQuat>;

  public static var Identity(default, never):FQuat;

	/**
	 * Checks whether another Quaternion is equal to this, within specified tolerance.
	 *
	 * @param Q The other Quaternion.
	 * @param Tolerance Error tolerance for comparison with other Quaternion.
	 * @return true if two Quaternions are equal, within specified tolerance, otherwise false.
	 */
  @:thisConst
  public function Equals(R:Const<PRef<FQuat>>, Tolerance:Float32=1e-4) : Bool;

  /** Convert a Quaternion into floating-point Euler angles (in degrees). */
	@:thisConst
  public function Euler() : FVector;

  /** Get the forward direction (X axis) after it has been rotated by this Quaternion. */
  @:thisConst
  public function GetForwardVector() : FVector;

  /** Get the right direction (Y axis) after it has been rotated by this Quaternion. */
  @:thisConst
  public function GetRightVector() : FVector;

  /** Get the up direction (Z axis) after it has been rotated by this Quaternion. */
  @:thisConst
  public function GetUpVector() : FVector;
}
