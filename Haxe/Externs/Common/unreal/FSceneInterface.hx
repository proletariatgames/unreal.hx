package unreal;

@:glueCppIncludes("Public/SceneInterface.h")
@:uextern @:noCopy @:noClass @:noEquals extern class FSceneInterface {
  public function AddLight(Light:ULightComponent) : Void;
}
