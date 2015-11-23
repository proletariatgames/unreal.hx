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

  @:thisConst
  public function GetAuthGameMode() : AGameMode;

  /**
   * Returns time in seconds since world was brought up for play, IS stopped when game pauses, IS dilated/clamped
   *
   * @return time in seconds since world was brought up for play
   */
  @:thisConst
  public function GetTimeSeconds() : Float32;

  /**
   * Returns the frame delta time in seconds adjusted by e.g. time dilation.
   *
   * @return frame delta time in seconds adjusted by e.g. time dilation
   */
  @:thisConst
  public function GetDeltaSeconds() : Float32;

  /**
   *  Trace a ray against the world using a specific channel and return the first blocking hit
   *  @param  OutHit          First blocking hit found
   *  @param  Start           Start location of the ray
   *  @param  End             End location of the ray
   *  @param  TraceChannel    The 'channel' that this ray is in, used to determine which components to hit
   *  @param  Params          Additional parameters used for the trace
   *  @param  ResponseParam ResponseContainer to be used for this trace  
   *  @return TRUE if a blocking hit is found
   */
  @:thisConst
  public function LineTraceSingleByChannel(OutHit:PRef<FHitResult>,Start:Const<PRef<FVector>>,End:Const<PRef<FVector>>, TraceChannel:ECollisionChannel, Params:Const<PRef<FCollisionQueryParams>>) : Bool;

  @:typeName public function SpawnActorDeferred<T>(
    aClass:UClass,
    transform:Const<PRef<FTransform>>,
    owner:AActor,
    instigator:APawn) : PExternal<T>;
}
