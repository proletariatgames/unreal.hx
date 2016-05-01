package unreal;

@:glueCppIncludes('Engine.h')
typedef FOnTravelFailure = MulticastDelegate<'UEngine.FOnTravelFailure',UWorld->ETravelFailure_Type->Const<PRef<FString>>->Void>;
