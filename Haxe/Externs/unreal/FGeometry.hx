package unreal;

@:glueCppIncludes("Layout/Geometry.h")
@:uextern extern class FGeometry {

	@:uname('new')
	static public function create() : PHaxeCreated<FGeometry>;

	@:thisConst
	public function ToString() : FString;
}
