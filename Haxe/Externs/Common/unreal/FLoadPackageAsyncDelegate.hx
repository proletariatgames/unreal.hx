package unreal;

@:glueCppIncludes("UObject/UObjectGlobals.h")
@:uname('FLoadPackageAsyncDelegate')
typedef FLoadPackageAsyncDelegate = Delegate<FLoadPackageAsyncDelegate, PRef<Const<unreal.FName>>->unreal.UPackage->unreal.EAsyncLoadingResult->Void>;
