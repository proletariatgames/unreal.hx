package unreal;

@:glueCppIncludes("IConsoleManager.h")
@:uextern @:noEquals @:noCopy @:noClass extern class IConsoleVariable {
  function AsVariableInt() : PExternal<TConsoleVariableData<Int32>>;
  function AsVariableFloat() : PExternal<TConsoleVariableData<Float32>>;
  function AsVariableString() : PExternal<TConsoleVariableData<FString>>;

  @:thisConst function GetInt() : Int32;
  @:thisConst function GetFloat() : Float32;
  @:thisConst function GetString() : FString;
}


