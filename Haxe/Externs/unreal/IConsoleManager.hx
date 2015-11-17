package unreal;

@:glueCppIncludes("IConsoleManager.h")
@:uextern @:noEquals @:noCopy @:noClass extern class IConsoleManager {
  public static function Get() : PRef<IConsoleManager>;

  @:thisConst public function FindTConsoleVariableDataInt(Name:TCharStar) : PExternal<TConsoleVariableData<Int32>>;
}
