package unreal;

@:glueCppIncludes("OnlineSubsystemTypes.h")
@:uname("FOnlineSessionInfo")
@:umodule("OnlineSubsystem")
@:ustruct
@:uextern @:noCopy @:noEquals extern class FOnlineSessionInfo extends IOnlinePlatformData {

	@:thisConst
	public function GetSessionId() : Const<PRef<FUniqueNetId>>;
}
