package unreal;

@:glueCppIncludes("ContentStreaming.h")
@:noCopy @:noEquals @:noClass @:uextern extern class FStreamingManagerCollection {
  public function StreamAllResources(TimeLimit:Float32) : Int32;
}
