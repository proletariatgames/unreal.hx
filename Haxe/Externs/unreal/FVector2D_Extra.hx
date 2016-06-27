package unreal;

extern class FVector2D_Extra {
  @:uname('.ctor') public static function createWithValues(x:Float32, y:Float32):FVector2D;
  @:uname('new') public static function createNewWithValues(x:Float32, y:Float32):POwnedPtr<FVector2D>;
  @:uname('.ctor') public static function copyCreate(InVector2D:Const<PRef<FVector2D>>) : FVector2D;

  public var X:Float32;
  public var Y:Float32;
}
