package unreal.slate;

@:glueCppIncludes("Public/Slate/SceneViewport.h")
@:uextern @:noCopy @:noEquals extern class FSceneViewport {
  public function HasMouseCapture() : Bool;
  public function CaptureMouse(bCapture:Bool) : Void;
}
