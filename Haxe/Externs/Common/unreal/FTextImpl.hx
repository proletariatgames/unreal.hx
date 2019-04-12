package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FText")
@:ustruct
@:uextern extern class FTextImpl {
  static function FromString(str:FString) : FTextImpl;
  function ToString():unreal.Const<unreal.PRef<FString>>;

  static function AsNumber(Val:Float32, Options:PPtr<Const<FNumberFormattingOptions>>, TargetCulture:TThreadSafeSharedPtr<FCulture>) : FTextImpl;

  @:expr(return ToString().op_Dereference()) public function toString():String;

	static function Format(Fmt:unreal.FTextFormat, InArguments:Const<PRef<unreal.FFormatNamedArguments>>) : FTextImpl;
}


