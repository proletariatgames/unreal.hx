package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FFormatArgumentValue")
@:uextern extern class FFormatArgumentValue {
  @:uname(".ctor") static function create():FFormatArgumentValue;
	@:uname(".ctor") static function createFromText(InText:Const<PRef<unreal.FText>>):FFormatArgumentValue;
	@:uname(".ctor") static function createFromFloat(InFloat:Const<unreal.Float32>):FFormatArgumentValue;
	@:uname(".ctor") static function createFromInt(InInt:Const<unreal.Int64>):FFormatArgumentValue;
	@:uname(".ctor") static function createFromUInt(InUInt:Const<unreal.UInt64>):FFormatArgumentValue;
	@:uname(".ctor") static function createFromDouble(InDouble:Const<Float>):FFormatArgumentValue;
	@:uname(".ctor") static function createFromGender(InFloat:Const<unreal.ETextGender>):FFormatArgumentValue;
}


