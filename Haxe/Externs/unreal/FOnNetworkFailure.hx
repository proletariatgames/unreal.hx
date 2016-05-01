package unreal;

@:glueCppIncludes('Engine.h')
typedef FOnNetworkFailure = MulticastDelegate<'UEngine.FOnNetworkFailure', UWorld->UNetDriver->ENetworkFailure->Const<PRef<FString>>->Void>;
