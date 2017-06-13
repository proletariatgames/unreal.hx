package unreal;

@:glueCppIncludes("IConsoleManager.h")
@:uextern @:noEquals @:noCopy @:noClass extern class IConsoleVariable {
  function AsVariableInt() : PPtr<TConsoleVariableData<Int32>>;
  function AsVariableFloat() : PPtr<TConsoleVariableData<Float32>>;
  function AsVariableString() : PPtr<TConsoleVariableData<FString>>;

  @:thisConst function GetInt() : Int32;
  @:thisConst function GetFloat() : Float32;
  @:thisConst function GetString() : FString;

  @:uname("Set") function SetString(InValue:TCharStar, SetBy:EConsoleVariableFlags):Void;
  @:uname("Set") function SetInt(InValue:Int32, SetBy:EConsoleVariableFlags):Void;
  @:uname("Set") function SetFloat(InValue:Float32, SetBy:EConsoleVariableFlags):Void;
}
