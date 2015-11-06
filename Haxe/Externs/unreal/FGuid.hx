package unreal;

@:glueCppIncludes("Misc/Guid.h")
@:ustruct
@:uextern extern class FGuid {

	@:uname('new')
	static public function create() : PHaxeCreated<FGuid>;

	@:thisConst
	public function ToString() : FString;
}
