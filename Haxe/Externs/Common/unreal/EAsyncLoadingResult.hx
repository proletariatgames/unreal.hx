package unreal;

@:glueCppIncludes("UObject/UObjectGlobals.h")
@:uname("EAsyncLoadingResult.Type")
@:uextern extern enum EAsyncLoadingResult
{
	Failed;
	Succeeded;
	Canceled;
}
