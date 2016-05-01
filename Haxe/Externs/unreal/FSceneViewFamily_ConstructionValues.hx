package unreal;

@:glueCppIncludes("Public/SceneView.h")
@:uextern @:uname("FSceneViewFamily.ConstructionValues")
@:noCopy @:noEquals extern class FSceneViewFamily_ConstructionValues {
  @:uname("new")
  public static function createStruct(InRenderTarget:Const<PPtr<FRenderTarget>>, InScene:PPtr<FSceneInterface>, InEngineShowFlags:Const<PRef<FEngineShowFlags>>) : POwnedPtr<FSceneViewFamily_ConstructionValues>;
}
