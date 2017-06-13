package unreal;

@:glueCppIncludes("IConsoleManager.h")
@:uextern @:noEquals @:noCopy @:noClass extern class IConsoleManager {
  public static function Get() : PRef<IConsoleManager>;

  @:thisConst public function FindTConsoleVariableDataInt(Name:TCharStar) : PPtr<TConsoleVariableData<Int32>>;
  @:thisConst public function FindTConsoleVariableDataFloat(Name:TCharStar) : PPtr<TConsoleVariableData<Float32>>;

  @:uname('RegisterConsoleVariable')
  public function RegisterIntConsoleVariable(Name:Const<TCharStar>, DefaultValue:Int32, Help:Const<TCharStar>) : PPtr<IConsoleVariable>;
  @:uname('RegisterConsoleVariable')
  public function RegisterFloatConsoleVariable(Name:Const<TCharStar>, DefaultValue:Float32, Help:Const<TCharStar>) : PPtr<IConsoleVariable>;
  @:uname('RegisterConsoleVariable')
  public function RegisterStringConsoleVariable(Name:Const<TCharStar>, DefaultValue:Const<PRef<FString>>, Help:Const<TCharStar>) : PPtr<IConsoleVariable>;

}
