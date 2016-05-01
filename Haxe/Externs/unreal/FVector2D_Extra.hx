package unreal;

extern class FVector2D_Extra {
  @:uname('new') public static function createWithValues(x:Float32, y:Float32):POwnedPtr<FVector2D>;

  public var X:Float32;
  public var Y:Float32;
}
