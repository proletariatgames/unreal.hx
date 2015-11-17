package unreal;

extern class FVector_Extra {
  @:uname('new') public static function createWithValues(x:Float32, y:Float32, z:Float32):PHaxeCreated<FVector>;

  @:uname('new') public static function createForceInit(e:EForceInit):PHaxeCreated<FVector>;

  /**
   * Gets a normalized copy of the 2D components of the vector, checking it is safe to do so. Z is set to zero. 
   * Returns zero vector if vector length is too small to normalize.
   *
   * @param Tolerance Minimum squared vector length.
   * @return Normalized copy if safe, otherwise returns zero vector.
   */
  @:thisConst
  public function GetSafeNormal2D() : PStruct<FVector>;

  @:thisConst
  public function Size() : Float32;

  public var X:Float32;
  public var Y:Float32;
  public var Z:Float32;
}
