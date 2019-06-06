package unreal;

extern class FVector2D_Extra {
  public function new(x:Float32, y:Float32);

  @:uname('.ctor') public static function createWithValues(x:Float32, y:Float32):FVector2D;
  @:uname('new') public static function createNewWithValues(x:Float32, y:Float32):POwnedPtr<FVector2D>;
  @:uname('.ctor') public static function copyCreate(InVector2D:Const<PRef<FVector2D>>) : FVector2D;

  public var X:Float32;
  public var Y:Float32;

  @:expr public static var ZeroVector (get,never) : Const<FVector2D>;

  @:expr public static var UnitVector (get,never) : Const<FVector2D>;

  @:expr({
    return createWithValues(0,0);
  }) private static function get_ZeroVector() : Const<FVector2D>;

  @:expr({
    return createWithValues(1,1);
  }) private static function get_UnitVector() : Const<FVector2D>;

  @:thisConst
  public function Equals(V:Const<PRef<FVector2D>>, Tolerance:Float32=1e-4) : Bool;

  @:op(A+B)
  @:expr(return createWithValues(X + b.X, Y + b.Y))
  public function _add(b:FVector2D):FVector2D;

  @:op(A*B)
  @:commutative
  @:expr(return createWithValues(X * b.X, Y * b.Y))
  public function _mul(b:FVector2D):FVector2D;

  @:op(A-B)
  @:expr(return createWithValues(X - b.X, Y - b.Y))
  public function _sub(b:FVector2D):FVector2D;

  @:op(A==B)
  @:expr(return X == b.X && Y == b.Y)
  public function _eq(b:FVector2D):Bool;

  public function Size():Float32;

  /**
  * Gets a normalized copy of the vector, checking it is safe to do so based on the length.
  * Returns zero vector if vector length is too small to safely normalize.
  *
  * @param Tolerance Minimum squared vector length.
  * @return A normalized copy if safe, (0,0,0) otherwise.
  */
  @:thisConst
  public function GetSafeNormal() : FVector2D;

  @:thisConst
  public function ClampAxes(MinAxisVal:Float32, MaxAxisVal:Float32) : FVector2D;
}
