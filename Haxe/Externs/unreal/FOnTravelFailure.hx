package unreal;

@:glueCppIncludes('Engine.h')
@:uname('UEngine.FOnTravelFailure')
typedef FOnTravelFailure = MulticastDelegate<FOnTravelFailure,UWorld->ETravelFailure_Type->Const<PRef<FString>>->Void>;
