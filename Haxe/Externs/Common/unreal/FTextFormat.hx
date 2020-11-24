package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FTextFormat")
@:uextern extern class FTextFormat {
  @:uname(".ctor") static function create():FTextFormat;
	@:uname(".ctor") static function createFromText(InText:Const<PRef<unreal.FText>>):FTextFormat;

  public static function FromString(InString:PRef<Const<FString>>) : FTextFormat;
}


