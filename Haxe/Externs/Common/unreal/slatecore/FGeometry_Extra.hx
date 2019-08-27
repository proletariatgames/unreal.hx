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

  @:thisConst
  public function GetAbsoluteSize() : unreal.FVector2D;

  @:thisConst
  public function GetAbsolutePosition() : unreal.FVector2D;

	/**
	 * Absolute coordinates could be either desktop or window space depending on what space the root of the widget hierarchy is in.
	 *
	 * @return Transforms AbsoluteCoordinate into the local space of this Geometry.
	 */
	@:thisConst
	public function AbsoluteToLocal(AbsoluteCoordinate:unreal.FVector2D) : unreal.FVector2D;
}
