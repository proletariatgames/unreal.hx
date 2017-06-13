package unreal;

extern class IConsoleManager_Extra {
  @:thisConst public function FindConsoleVariable(Name:TCharStar) : PPtr<IConsoleVariable>;
  public function RegisterConsoleCommand(name:TCharStar, help:TCharStar, command:PRef<FConsoleCommandWithArgsDelegate>, flags:Int32) : PPtr<IConsoleCommand>;
}
