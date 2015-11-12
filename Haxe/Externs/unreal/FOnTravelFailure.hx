package unreal;

@:glueCppIncludes('Engine.h')
@:uname('UEngine.FOnTravelFailure')
@:uextern extern class FOnTravelFailure extends MulticastDelegate<UWorld->ETravelFailure_Type->Const<PRef<FString>>->Void> {}
