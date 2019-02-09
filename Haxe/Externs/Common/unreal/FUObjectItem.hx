package unreal;

@:glueCppIncludes("UObject/UObjectArray.h")
@:noCopy @:noEquals
@:uextern extern class FUObjectItem {

	@:thisConst
	public function GetOwnerIndex() : Int32;
}
