package unreal;

@:glueCppIncludes("Internationalization/Text.h")
extern class FFormatArgumentData_Extra {
  @:uname(".ctor") static function create():FFormatArgumentData;

	@:expr(return { var d = create(); d.ArgumentName = InName; d.ArgumentValueType = EFormatArgumentType.Text; d.ArgumentValue = InText; d; })
	static function createFromText(InName:PRef<Const<FString>>, InText:Const<PRef<unreal.FText>>):FFormatArgumentData;

	@:expr(return { var d = create(); d.ArgumentName = InName; d.ArgumentValueType = EFormatArgumentType.Float; d.ArgumentValueFloat = InFloat; d; })
	static function createFromFloat(InName:PRef<Const<FString>>, InFloat:Const<unreal.Float32>):FFormatArgumentData;

	@:expr(return { var d = create(); d.ArgumentName = InName; d.ArgumentValueType = EFormatArgumentType.Int; d.ArgumentValueInt = InInt; d; })
	static function createFromInt(InName:PRef<Const<FString>>, InInt:Const<Int32>):FFormatArgumentData;

	@:expr(return { var d = create(); d.ArgumentName = InName; d.ArgumentValueType = EFormatArgumentType.Gender; d.ArgumentValueGender = InGender; d; })
	static function createFromGender(InName:PRef<Const<FString>>, InGender:Const<unreal.ETextGender>):FFormatArgumentData;

	public var ArgumentValueType:TEnumAsByte<unreal.EFormatArgumentType>;
	public var ArgumentName:FString;
	public var ArgumentValue:FText;
	public var ArgumentValueInt:Int32;
	public var ArgumentValueFloat:Float32;
	public var ArgumentValueGender:ETextGender;
}


