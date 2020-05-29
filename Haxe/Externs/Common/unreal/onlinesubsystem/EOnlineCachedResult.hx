package unreal.onlinesubsystem;


@:umodule("OnlineSubsystem")
@:glueCppIncludes("OnlineSubsystemTypes.h")
@:uname("EOnlineCachedResult.Type")
@:uextern extern enum EOnlineCachedResult {
	Success; /** The requested data was found and returned successfully. */
	NotFound; /** The requested data was not found in the cache, and the out parameter was not modified. */
}
