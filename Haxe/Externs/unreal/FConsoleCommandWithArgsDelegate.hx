package unreal;

@:glueCppIncludes("HAL/IConsoleManager.h")
typedef FConsoleCommandWithArgsDelegate = Delegate<'FConsoleCommandWithArgsDelegate', Const<PRef<TArray<FString>>>->Void>;
