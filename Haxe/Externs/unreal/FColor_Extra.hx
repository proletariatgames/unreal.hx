package unreal;

extern class FColor_Extra {
  @:uname(".ctor")
  public static function create() : FColor;
  @:uname("new")
  public static function createNew() : POwnedPtr<FColor>;

  @:uname(".ctor")
  public static function createWithValues(r:UInt8,g:UInt8,b:UInt8,a:UInt8) : FColor;
  @:uname("new")
  public static function createNewWithValues(r:UInt8,g:UInt8,b:UInt8,a:UInt8) : POwnedPtr<FColor>;

  public static function FromHex(HexString:Const<PRef<FString>>) : FColor;

  @:thisConst
  public function ReinterpretAsLinear() : FLinearColor;
}

