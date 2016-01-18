package unreal;

@:glueCppIncludes('Engine.h')
@:uname('UEngine.FOnNetworkFailure')
@:uextern extern class FOnNetworkFailure extends MulticastDelegate<UWorld->UNetDriver->ENetworkFailure->Const<PRef<FString>>->Void> {}
