package unreal;

@:glueCppIncludes("HAL/IConsoleManager.h")
@:uextern extern class FConsoleCommandWithArgsDelegate extends Delegate<Const<PRef<TArray<FString>>>->Void> {}
