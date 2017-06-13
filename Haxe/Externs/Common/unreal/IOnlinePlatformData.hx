package unreal;

@:glueCppIncludes("OnlineSubsystemTypes.h")
@:umodule("OnlineSubsystem")
@:uextern @:noCopy @:noEquals extern class IOnlinePlatformData {

	@:thisConst
	public function GetSize() : Int32;

	@:thisConst
	public function IsValid() : Bool;

	@:thisConst
	public function ToString() : FString;

	@:thisConst
	public function ToDebugString() : FString;
}
