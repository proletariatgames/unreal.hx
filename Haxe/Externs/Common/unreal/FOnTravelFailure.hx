package unreal;

@:glueCppIncludes('Engine/Engine.h')
@:uname('UEngine.FOnTravelFailure')
typedef FOnTravelFailure = MulticastDelegate<FOnTravelFailure,UWorld->ETravelFailure->Const<PRef<FString>>->Void>;
