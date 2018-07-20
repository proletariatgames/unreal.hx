package unreal;

@:glueCppIncludes('Engine/Engine.h')
@:uname('UEngine.FOnNetworkFailure')
typedef FOnNetworkFailure = MulticastDelegate<FOnNetworkFailure, UWorld->UNetDriver->ENetworkFailure->Const<PRef<FString>>->Void>;
