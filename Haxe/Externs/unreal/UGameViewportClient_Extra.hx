package unreal;

@:glueCppIncludes("Engine/GameViewportClient.h")
@:uextern extern class UGameViewportClient_Extra extends unreal.UScriptViewportClient {

  public var Viewport : PPtr<FViewport>;

  public var EngineShowFlags : FEngineShowFlags;

  @:thisConst
  public function GetViewportSize( ViewportSize:FVector2D ) : Void;
}
