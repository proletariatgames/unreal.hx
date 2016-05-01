package unreal;

extern class ULocalPlayer_Extra {
  @:thisConst
  public function GetNickname() : FString;

  public function CalcSceneView(ViewFamily:PPtr<FSceneViewFamily>,
                                OutViewLocation : PRef<FVector>,
                                OutViewRotation: PRef<FRotator>,
                                Viewport:PPtr<FViewport>,
                                ViewDrawer:PPtr<FViewElementDrawer>,
                                StereoPass:EStereoscopicPass) : PPtr<FSceneView>;
}
