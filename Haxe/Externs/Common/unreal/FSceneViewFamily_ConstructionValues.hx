package unreal;

@:glueCppIncludes("Public/SceneView.h")
@:uextern @:uname("FSceneViewFamily.ConstructionValues")
@:noCopy @:noEquals extern class FSceneViewFamily_ConstructionValues {
  @:uname(".ctor")
  public static function create(InRenderTarget:PPtr<Const<FRenderTarget>>, InScene:PPtr<FSceneInterface>, InEngineShowFlags:Const<PRef<FEngineShowFlags>>) : FSceneViewFamily_ConstructionValues;
  @:uname("new")
  public static function createNew(InRenderTarget:PPtr<Const<FRenderTarget>>, InScene:PPtr<FSceneInterface>, InEngineShowFlags:Const<PRef<FEngineShowFlags>>) : POwnedPtr<FSceneViewFamily_ConstructionValues>;
}
