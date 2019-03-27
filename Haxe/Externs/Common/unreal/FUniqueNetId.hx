package unreal;

@:glueCppIncludes("OnlineSubsystemTypes.h")
@:umodule("OnlineSubsystem")
@:uextern @:noCopy @:hasEquals extern class FUniqueNetId {
	@:thisConst
	public function GetSize() : Int32;

	@:thisConst
	public function IsValid() : Bool;

	@:thisConst
	public function ToString() : FString;

	@:thisConst
	public function ToDebugString() : FString;
}
