package unreal;

@:glueCppIncludes("Public/UnrealClient.h")
@:uextern @:noCopy @:noEquals extern class FViewport extends FRenderTarget {
  public function SetMouse(X:Int32, Y:Int32) : Void;
}
