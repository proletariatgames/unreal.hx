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

  public function ToHex() : FString;

  @:thisConst
  public function ReinterpretAsLinear() : FLinearColor;

  public static var White(default,never) : FColor;
  public static var Black(default,never) : FColor;
  public static var Transparent(default,never) : FColor;
  public static var Red(default,never) : FColor;
  public static var Green(default,never) : FColor;
  public static var Blue(default,never) : FColor;
  public static var Yellow(default,never) : FColor;
  public static var Cyan(default,never) : FColor;
  public static var Magenta(default,never) : FColor;
  public static var Orange(default,never) : FColor;
  public static var Purple(default,never) : FColor;
  public static var Turquoise(default,never) : FColor;
  public static var Silver(default,never) : FColor;
  public static var Emerald(default,never) : FColor;
}
