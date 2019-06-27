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

  inline public static function asTimespan(Timespan:Const<PRef<FTimespan>>, TargetCulture:TThreadSafeSharedPtr<FCulture>) : FTextImpl {
    return FTextImpl.AsTimespan(Timespan, TargetCulture);
  }

  inline public static function asHourMinuteTimespan(Timespan:Const<PRef<FTimespan>>, TargetCulture:TThreadSafeSharedPtr<FCulture>) : FTextImpl {
    return FTextImpl.AsHourMinuteTimespan(Timespan, TargetCulture);
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

  public static function FormatArray(fmt:FTextFormat, arguments:Array<Dynamic>)
  {
    var ret:TArray<FFormatArgumentValue> = TArray.create();
    var i = -1;
    for (arg in arguments) {
      i++;
      var fmtArg = getFormatArgument(arg);
      if (fmtArg == null) {
        throw 'Invalid format argument number $i `$arg`';
      }
      ret.push(fmtArg);
    }
    return FTextImpl.FormatOrdered(fmt, ret);
  }

  private static function getFormatArgument(arg:Dynamic):FFormatArgumentValue {
    if (Std.is(arg, Int)) {
      return (FFormatArgumentValue.createFromInt(arg));
    } else if (Std.is(arg, Float)) {
      return (FFormatArgumentValue.createFromDouble(arg));
    } else if (Std.is(arg, ETextGender)) {
      return (FFormatArgumentValue.createFromGender(arg));
    } else if (Std.is(arg, String)) {
      return (FFormatArgumentValue.createFromText((arg : String)));
    } else {
      return null;
    }
  }

  public static function FormatMap(fmt:FTextFormat, arguments:Map<String, Dynamic>)
  {
    var ret = FFormatNamedArguments.create();
    var i = -1;
    for (key in arguments.keys()) {
      i++;
      var arg = arguments[key];
      var fmtArg = getFormatArgument(arg);
      if (fmtArg == null) {
        throw 'Invalid format argument $key `$arg`';
      }
      ret.Add(key, fmtArg);
    }
    return FTextImpl.Format(fmt, ret);
  }
#end
}
