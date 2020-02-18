package unreal.onlinesubsystem;

/**
 * Union of all the platform informational message types we handle (some may be handled by more than one platform)
 */
@:glueCppIncludes("OnlineExternalUIInterface.h") @:umodule("OnlineSubsystem")
@:uname("EPlatformMessageType")
@:class @:uextern extern enum EPlatformMessageType
{
	EmptyStore;
	ChatRestricted;
	UGCRestricted;
}