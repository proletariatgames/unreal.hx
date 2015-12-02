package unreal;

@:glueCppIncludes("Engine/GameViewportClient.h")
@:uextern extern class UGameViewportClient_Extra extends unreal.UScriptViewportClient {

  public var Viewport : PExternal<FViewport>;

  public var EngineShowFlags : FEngineShowFlags;

  @:thisConst
  public function GetViewportSize( ViewportSize:FVector2D ) : Void;
}
