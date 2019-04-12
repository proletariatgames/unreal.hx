package unreal;

@:forward abstract FText(FTextImpl) from FTextImpl to FTextImpl #if !bake_externs to Struct to VariantPtr #end {
#if !bake_externs
  inline public function new(str:String) {
    this = FTextImpl.FromString(str);
  }

  inline public static function create(str:String):FText {
    return FTextImpl.FromString(str);
  }

  inline public static function asNumber(Val:Float32, Options:Const<PPtr<FNumberFormattingOptions>>, TargetCulture:TThreadSafeSharedPtr<FCulture>) : FTextImpl {
    return FTextImpl.AsNumber(Val, Options, TargetCulture);
  }

  @:from inline public static function fromString(str:String):FText {
    return create(str);
  }

  public static function FromString(str:FString) : FText {
    return FTextImpl.FromString(str);
  }

  public function toString():String {
    return this.ToString().toString();
  }

	inline public static function Format(Fmt:unreal.FTextFormat, InArguments:Const<PRef<unreal.FFormatNamedArguments>>) : FText
	{
		return FTextImpl.Format(Fmt, InArguments);
	}
#end
}
