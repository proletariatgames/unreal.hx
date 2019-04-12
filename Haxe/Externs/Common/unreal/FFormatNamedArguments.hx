package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FFormatNamedArguments")
@:uextern extern class FFormatNamedArguments
{
	@:uname('.ctor') static function create():FFormatNamedArguments;
	public function Add(InKey:unreal.FString, InValue:unreal.FFormatArgumentValue):Void;
}
