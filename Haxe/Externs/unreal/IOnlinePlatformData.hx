package unreal;

@:glueCppIncludes("Online/OnlineSubsystem/Public/OnlineSubsystemTypes.h")
@:uname("IOnlinePlatformData")
@:uextern extern class IOnlinePlatformData {

	@:thisConst
	public function GetSize() : Int32;

	@:thisConst
	public function IsValid() : Bool;

	@:thisConst
	public function ToString() : FString;

	@:thisConst
	public function ToDebugString() : FString;

	@:thisConst
	public function GetSessionId() : Const<PRef<FUniqueNetIdString>>;
}