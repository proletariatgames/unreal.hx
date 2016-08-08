package unreal;

@:glueCppIncludes("ContentStreaming.h")
@:noCopy @:noEquals @:noClass @:uextern extern class IStreamingManager {

  public static function Get() : PRef<FStreamingManagerCollection>;

}
