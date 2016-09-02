package unreal.slatecore;

@:umodule("SlateCore")

@:glueCppIncludes("Layout/Geometry.h")
@:uextern extern class FGeometry_Extra {

  @:uname('.ctor')
  static public function create() : FGeometry;
  @:uname('new')
  static public function createNew() : POwnedPtr<FGeometry>;

  @:thisConst
  public function ToString() : FString;

  @:thisConst
  public function GetLocalSize() : Const<PRef<unreal.FVector2D>>;
}
