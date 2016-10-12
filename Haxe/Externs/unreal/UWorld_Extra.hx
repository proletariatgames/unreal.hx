package unreal;

extern class UWorld_Extra {
  /** Time in seconds since level began play, but is NOT paused when the game is paused, and is NOT dilated/clamped. */
  public var RealTimeSeconds : Float32;

  public var Scene : PPtr<FSceneInterface>;

  @:thisConst
  public function GetGameState() : AGameState;

  @:thisConst
  public function GetGameInstance() : UGameInstance;

  @:thisConst
  public function GetGameViewport() : UGameViewportClient;

  @:thisConst
  public function IsPlayInEditor() : Bool;

  @:thisConst
  public function GetControllerIterator() : TConstArrayIteratorWrapper<TAutoWeakObjectPtr<AController>>;

  @:thisConst
  public function GetFirstPlayerController() : APlayerController;

  @:thisConst
  public function GetPawnIterator() : TConstArrayIteratorWrapper<TAutoWeakObjectPtr<APawn>>;

  public function SpawnActor(cls:UClass, location:PPtr<Const<FVector>>, rotator:PPtr<Const<FRotator>>, spawnParameters:Const<PRef<FActorSpawnParameters>>) : AActor;

  /**
   * Removes the actor from its level's actor list and generally cleans up the engine's internal state.
   * What this function does not do, but is handled via garbage collection instead, is remove references
   * to this actor from all other actors, and kill the actor's resources.  This function is set up so that
   * no problems occur even if the actor is being destroyed inside its recursion stack.
   *
   * @param	ThisActor				Actor to remove.
   * @param	bNetForce				[opt] Ignored unless called during play.  Default is false.
   * @param	bShouldModifyLevel		[opt] If true, Modify() the level before removing the actor.  Default is true.
   * @return							true if destroyed or already marked for destruction, false if actor couldn't be destroyed.
   */
  public function DestroyActor(actor:AActor, bNetForce:Bool, bShouldModifyLevel:Bool) : Bool;

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
	* Returns time in seconds since world was brought up for play, does NOT stop when game pauses, NOT dilated/clamped
	*
	* @return time in seconds since world was brought up for play
	*/
  @:thisConst
	public function GetRealTimeSeconds() : Float32;

  /**
	* Returns time in seconds since world was brought up for play, IS stopped when game pauses, NOT dilated/clamped
	*
	* @return time in seconds since world was brought up for play
	*/
  @:thisConst
  public function GetAudioTimeSeconds() : Float32;

  /**
   * Returns the frame delta time in seconds adjusted by e.g. time dilation.
   *
   * @return frame delta time in seconds adjusted by e.g. time dilation
   */
  @:thisConst
  public function GetDeltaSeconds() : Float32;

	/** Return the URL of this level on the local machine. */
  @:thisConst
	function GetLocalURL() : FString;

	// Return the URL of this level, which may possibly
	// exist on a remote machine.
  @:thisConst
	function GetAddressURL() : FString;

	/**
	 * Returns the name of the current map, taking into account using a dummy persistent world
	 * and loading levels into it via PrepareMapChange.
	 *
	 * @return	name of the current map
	 */
   @:thisConst
	 function GetMapName() : FString;

  /**
   * Jumps the server to new level.  If bAbsolute is true and we are using seemless traveling, we
   * will do an absolute travel (URL will be flushed).
   *
   * @param URL the URL that we are traveling to
   * @param bAbsolute whether we are using relative or absolute travel
   * @param bShouldSkipGameNotify whether to notify the clients/game or not
   */
  public function ServerTravel(InURL:Const<PRef<FString>>, bAbsolute:Bool=false, bShouldSkipGameNotify:Bool=false) : Void;

  public function IsInSeamlessTravel() : Bool;

  /**
    Returns TimerManager instance for this world.
   **/
  public function GetTimerManager() : PRef<FTimerManager>;

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

	/**
	 *  Trace a ray against the world using a specific channel and return overlapping hits and then first blocking hit
	 *  Results are sorted, so a blocking hit (if found) will be the last element of the array
	 *  Only the single closest blocking result will be generated, no tests will be done after that
	 *  @param  OutHits         Array of hits found between ray and the world
	 *  @param  Start           Start location of the ray
	 *  @param  End             End location of the ray
	 *  @param  TraceChannel    The 'channel' that this ray is in, used to determine which components to hit
	 *  @param  Params          Additional parameters used for the trace
	 * 	@param 	ResponseParam	ResponseContainer to be used for this trace
	 *  @return TRUE if OutHits contains any blocking hit entries
	 */
  @:thisConst
  public function LineTraceMultiByChannel(OutHits:PRef<TArray<FHitResult>>, Start:Const<PRef<FVector>>,End:Const<PRef<FVector>>, TraceChannel:ECollisionChannel, Params:Const<PRef<FCollisionQueryParams>>) : Bool;

  @:thisConst
  public function SweepSingleByChannel(OutHit:PRef<FHitResult>, Start:Const<PRef<FVector>>, End:Const<PRef<FVector>>, Rot:Const<PRef<FQuat>>, TraceChannel:ECollisionChannel, Shape:Const<PRef<FCollisionShape>>, Params:Const<PRef<FCollisionQueryParams>>) : Bool;

  @:typeName public function SpawnActorDeferred<T>(
    aClass:UClass,
    transform:Const<PRef<FTransform>>,
    owner:AActor,
    instigator:APawn) : PPtr<T>;

  /**
    Test the collision of a shape at the supplied location using a specific channel, and return if any blocking overlap is found
   **/
  function OverlapBlockingTestByChannel(
      pos:Const<PRef<FVector>>,
      rot:Const<PRef<FQuat>>,
      traceChannel:ECollisionChannel,
      collisionShape:Const<PRef<FCollisionShape>>,
      params:Const<PRef<FCollisionQueryParams>>,
      responseParam:Const<PRef<FCollisionResponseParams>>):Bool;


	/**
	 *  Test the collision of a shape at the supplied location using a specific channel, and determine the set of components that it overlaps
	 *  @param  OutOverlaps     Array of components found to overlap supplied box
	 *  @param  Pos             Location of center of shape to test against the world
	 *  @param  TraceChannel    The 'channel' that this query is in, used to determine which components to hit
	 *  @param	CollisionShape	CollisionShape - supports Box, Sphere, Capsule
	 *  @param  Params          Additional parameters used for the trace
	 * 	@param 	ResponseParam	ResponseContainer to be used for this trace
	 *  @return TRUE if OutOverlaps contains any blocking results
	 */
  @:thisConst
	function OverlapMultiByChannel(
    OutOverlaps:PRef<TArray<FOverlapResult>>,
    Pos:Const<PRef<FVector>>,
    Rot:Const<PRef<FQuat>>,
    TraceChannel:ECollisionChannel,
    CollisionShape:Const<PRef<FCollisionShape>>,
    Params:Const<PRef<FCollisionQueryParams>>,
    ResponseParam:Const<PRef<FCollisionResponseParams>>
  ) : Bool;

  /**
    Returns the AWorldSettings actor associated with this world.
   **/
  function GetWorldSettings(bCheckStreamingPesistent:Bool, bChecked:Bool):AWorldSettings;

	/** Gets this world's instance for a given collection. */
  function GetParameterCollectionInstance(Collection:Const<UMaterialParameterCollection>) : UMaterialParameterCollectionInstance;
}
