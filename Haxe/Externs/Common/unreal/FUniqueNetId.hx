package unreal;

@:glueCppIncludes("UObject/CoreOnline.h")
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
