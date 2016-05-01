package unreal;

extern class FVector_Extra {
  @:uname('new') public static function createWithValues(x:Float32, y:Float32, z:Float32):POwnedPtr<FVector>;

  @:uname('new') public static function createForceInit(e:EForceInit):POwnedPtr<FVector>;

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
  public function Rotation() : FRotator;

  public var X:Float32;
  public var Y:Float32;
  public var Z:Float32;

  public static var ZeroVector (get,never) : Const<FVector>;

  public static var UpVector (get,never) : Const<FVector>;

  public static var ForwardVector (get,never) : Const<FVector>;

  public static var RightVector (get,never) : Const<FVector>;

  public function HeadingAngle() : Float32;
}
