package unreal;

@:glueCppIncludes("Public/SceneView.h")
@:uextern @:uname("FSceneViewFamily.ConstructionValues")
@:noCopy @:noEquals extern class FSceneViewFamily_ConstructionValues {
  @:uname("new")
  public static function createStruct(InRenderTarget:Const<PExternal<FRenderTarget>>, InScene:PExternal<FSceneInterface>, InEngineShowFlags:Const<PRef<FEngineShowFlags>>) : PHaxeCreated<FSceneViewFamily_ConstructionValues>;
}
