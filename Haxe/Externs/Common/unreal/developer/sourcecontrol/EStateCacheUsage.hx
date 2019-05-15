package unreal.developer.sourcecontrol;

@:glueCppIncludes("ISourceControlProvider.h")
@:uname("EStateCacheUsage.Type")
@:uextern extern enum EStateCacheUsage
{
		/** Force a synchronous update of the state of the file. */
		ForceUpdate;
		/** Use the cached state if possible */
		Use;
}
