package unreal;

extern class ULocalPlayer_Extra {
  @:thisConst
  public function GetNickname() : FString;

  /**
   * Retrieves any game-specific login options for this player
   * if this function returns a non-empty string, the returned option or options be added
   * passed in to the level loading and connection code.  Options are in URL format,
   * key=value, with multiple options concatenated together with an & between each key/value pair
   *
   * @return URL Option or options for this game, Empty string otherwise
   */
  @:thisConst
    public function GetGameLoginOptions() : FString;

  /**
   * Get the game instance associated with this local player
   *
   * @return GameInstance related to local player
   */
  @:thisConst
    public function GetGameInstance() : UGameInstance;


  /**
   * Called at creation time for internal setup
   */
  public function PlayerAdded(InViewportClient:UGameViewportClient, InControllerID:Int32) : Void;

  public function CalcSceneView(ViewFamily:PPtr<FSceneViewFamily>,
                                OutViewLocation : PRef<FVector>,
                                OutViewRotation: PRef<FRotator>,
                                Viewport:PPtr<FViewport>,
                                ViewDrawer:PPtr<FViewElementDrawer>,
                                StereoPass:EStereoscopicPass) : PPtr<FSceneView>;
								
  @:thisConst
    public function GetPreferredUniqueNetId() : TSharedPtr<Const<FUniqueNetId>>;
}
