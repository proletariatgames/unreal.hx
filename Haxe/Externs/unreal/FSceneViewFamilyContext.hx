package unreal;

@:glueCppIncludes("Public/SceneView.h")
@:uextern @:noCopy @:noEquals extern class FSceneViewFamilyContext extends FSceneViewFamily {

  @:uname(".ctor")
  public static function create(CVS:FSceneViewFamily_ConstructionValues) : FSceneViewFamilyContext;

}
