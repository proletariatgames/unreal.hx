package unreal;

extern class ULocalPlayer_Extra {
  @:thisConst
  public function GetNickname() : FString;

  public function CalcSceneView(ViewFamily:PExternal<FSceneViewFamily>,
                                OutViewLocation : PRef<FVector>,
                                OutViewRotation: PRef<FRotator>,
                                Viewport:PExternal<FViewport>,
                                ViewDrawer:PExternal<FViewElementDrawer>,
                                StereoPass:EStereoscopicPass) : PExternal<FSceneView>;
}
