package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FFormatArgumentValue")
@:uextern extern class FFormatArgumentValue {
  @:uname(".ctor") static function create():FFormatArgumentValue;
	@:uname(".ctor") static function createFromText(InText:Const<PRef<unreal.FText>>):FFormatArgumentValue;
	@:uname(".ctor") static function createFromFloat(InFloat:Const<unreal.Float32>):FFormatArgumentValue;
}


