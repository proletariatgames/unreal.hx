package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("FText")
@:ustruct
@:uextern extern class FTextImpl {
  static function FromString(str:FString) : FTextImpl;
  function ToString():unreal.Const<unreal.PRef<FString>>;

  static function AsNumber(Val:Float32, Options:PPtr<Const<FNumberFormattingOptions>>, TargetCulture:TThreadSafeSharedPtr<FCulture>) : FTextImpl;

  static function AsTimespan(Timespan:Const<PRef<FTimespan>>, TargetCulture:TThreadSafeSharedPtr<FCulture>) : FTextImpl;
  #if proletariat
  static function AsHourMinuteTimespan(Timespan:Const<PRef<FTimespan>>, TargetCulture:TThreadSafeSharedPtr<FCulture>) : FTextImpl;
  #end

  @:expr(return ToString().op_Dereference()) public function toString():String;

	static function Format(Fmt:unreal.FTextFormat, InArguments:Const<PRef<unreal.FFormatNamedArguments>>) : FTextImpl;
	@:uname("Format") static function FormatOrdered(Fmt:unreal.FTextFormat, InArguments:Const<PRef<TArray<FFormatArgumentValue>>>) : FTextImpl;

  @:thisConst
  function ToUpper():FText;
  @:thisConst
  function ToLower():FText;

  @:expr public static var EmptyText (get,never) : Const<FText>;
  @:expr({
    return FTextImpl.GetEmpty();
  }) private static function get_EmptyText() : Const<FText>;

  function IsEmpty():Bool;

	/**
	 * Generate an FText that represents the passed number in the current culture
	 */
  @:uname("AsNumber") static function FromInt(val:Int32, FormattingOptions:Const<PPtr<FNumberFormattingOptions>>=null) : Const<FText>;
  static function AsPercent(val:Float32, FormattingOptions:Const<PPtr<FNumberFormattingOptions>>=null) : Const<FText>;

  private static function GetEmpty() : PRef<Const<FText>>;
}


