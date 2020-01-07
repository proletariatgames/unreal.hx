package unreal;

import unreal.FOnViewportResized;

extern class FViewport_Extra {
  public static var ViewportResizedEvent:FOnViewportResized;

  // Accessors.
  @:thisConst
  public function GetClient() : PPtr<FViewportClient>;
}
