package unreal;

extern class FVector2D_Extra {
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
}
