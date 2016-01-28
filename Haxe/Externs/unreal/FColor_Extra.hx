package unreal;

extern class FColor_Extra {
  @:uname("new")
  public static function create() : PHaxeCreated<FColor>;

  @:uname("new")
  public static function createWithValues(r:UInt8,g:UInt8,b:UInt8,a:UInt8) : PHaxeCreated<FColor>;

  @:thisConst
  public function ReinterpretAsLinear() : FLinearColor;
}

