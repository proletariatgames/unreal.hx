package unreal;

@:glueCppIncludes("Engine/EngineTypes.h")
@:class @:uname("EFlushLevelStreamingType") @:uextern extern enum EFlushLevelStreamingType
{
	/** Do not flush state on change */
	None;
	/** Allow multiple load requests */
	Full;
	/** Flush visibility only, do not allow load requests, flushes async loading as well */
	Visibility;
}
