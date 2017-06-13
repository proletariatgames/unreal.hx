package unreal;

@:glueCppIncludes("Public/SceneView.h")
@:uextern @:noCopy @:noEquals extern class FSceneView {

  @:thisConst
  public function WorldToPixel(WorldPoint:Const<PRef<FVector>>, OutPixelLocation:PRef<FVector2D>) : Bool;

}
