package unreal;

extern class UGameInstance_Extra {
  /** virtual function to allow custom GameInstances an opportunity to set up what it needs */
  @:uexpose
  public function Init() : Void;

  /** virtual function to allow custom GameInstances an opportunity to do cleanup when shutting down */
  public function Shutdown() : Void;

  @:thisConst
  public function GetFirstLocalPlayerController() : Const<APlayerController>;

  @:thisConst
  public function GetLocalPlayers() : Const<PRef<TArray<ULocalPlayer>>>;

  @:thisConst
  public function GetTimerManager() : PRef<FTimerManager>;
}
