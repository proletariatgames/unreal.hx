package unreal;

extern class UWorld_Extra {
  /** Time in seconds since level began play, but is NOT paused when the game is paused, and is NOT dilated/clamped. */
  public var RealTimeSeconds : Float32;

  @:thisConst
  public function GetGameState() : AGameState;

  @:thisConst
  public function GetGameInstance() : UGameInstance;

  @:thisConst
  public function IsPlayInEditor() : Bool;

  @:thisConst
  public function GetControllerIterator() : TConstArrayIteratorWrapper<TAutoWeakObjectPtr<AController>>;

  @:thisConst
  public function GetPawnIterator() : TConstArrayIteratorWrapper<TAutoWeakObjectPtr<APawn>>;

  public function SpawnActor(cls:UClass, location:Const<PExternal<FVector>>, rotator:Const<PExternal<FRotator>>, spawnParameters:Const<PRef<FActorSpawnParameters>>) : AActor;
}
