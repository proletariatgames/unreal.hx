package unreal;

@:glueCppIncludes("Public/SceneView.h")
@:uextern @:noCopy @:noEquals extern class FSceneView {

  @:thisConst
  public function WorldToPixel(WorldPoint:FVector, OutPixelLocation:FVector2D) : Bool;

}
