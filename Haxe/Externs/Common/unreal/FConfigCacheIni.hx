package unreal;

@:glueCppIncludes("Misc/ConfigCacheIni.h")
@:uextern extern class FConfigCacheIni
{
  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GConfig(default, never):PPtr<FConfigCacheIni>;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GEngineIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GEditorIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GCompatIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GLightmassIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GScalabilityIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GHardwareIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GInputIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GGameIni(default, never):FString;

  @:global
  @:glueCppIncludes("CoreGlobals.h")
  public static var GGameUserSettingsIni(default, never):FString;

  public function GetString( Section:TCharStar, Key:TCharStar, Value:PRef<FString>, Filename:Const<PRef<FString>>):Bool;
  public function GetText( Section:TCharStar, Key:TCharStar, Value:PRef<FText>, Filename:Const<PRef<FString>> ):Bool;
  public function GetInt(Section:TCharStar, Key:TCharStar, Value:Ref<Int>, Filename:Const<PRef<FString>>):Bool;
  public function GetFloat(Section:TCharStar, Key:TCharStar, Value:Ref<Float32>, Filename:Const<PRef<FString>>):Bool;
  public function GetDouble(Section:TCharStar, Key:TCharStar, Value:Ref<Float>, Filename:Const<PRef<FString>>):Bool;
  public function GetBool( Section:TCharStar, Key:TCharStar, Value:Ref<Bool>, Filename:Const<PRef<FString>> ):Bool;
  public function GetArray(Section:TCharStar, Key:TCharStar, Value:PRef<TArray<FString>>, Filename:Const<PRef<FString>>):Int;

  public function SetString( Section:TCharStar, Key:TCharStar, Value:TCharStar, Filename:Const<PRef<FString>>):Void;
  public function SetText( Section:TCharStar, Key:TCharStar, Value:Const<PRef<FText>>, Filename:Const<PRef<FString>> ):Void;
  public function SetInt( Section:TCharStar, Key:TCharStar, Value:Int, Filename:Const<PRef<FString>> ):Void;
  public function SetFloat( Section:TCharStar, Key:TCharStar, Value:Float32, Filename:Const<PRef<FString>> ):Void;
  public function SetDouble( Section:TCharStar, Key:TCharStar, Value:Float, Filename:Const<PRef<FString>> ):Void;
  public function SetBool( Section:TCharStar, Key:TCharStar, Value:Bool, Filename:Const<PRef<FString>> ):Void;
}
