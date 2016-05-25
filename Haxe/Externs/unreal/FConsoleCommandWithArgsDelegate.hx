package unreal;

@:glueCppIncludes("HAL/IConsoleManager.h")
@:uname('FConsoleCommandWithArgsDelegate')
typedef FConsoleCommandWithArgsDelegate = Delegate<FConsoleCommandWithArgsDelegate, Const<PRef<TArray<FString>>>->Void>;
