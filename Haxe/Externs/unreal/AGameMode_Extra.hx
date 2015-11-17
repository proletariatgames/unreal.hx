package unreal;


extern class AGameMode_Extra {
  @:global("MatchState")
  public static var EnteringMap(default,never):Const<PStruct<FName>>;
  @:global("MatchState")
  public static var WaitingToStart(default,never):Const<PStruct<FName>>;
  @:global("MatchState")
  public static var InProgress(default,never):Const<PStruct<FName>>;
  @:global("MatchState")
  public static var WaitingPostMatch(default,never):Const<PStruct<FName>>;
  @:global("MatchState")
  public static var LeavingMap(default,never):Const<PStruct<FName>>;
  @:global("MatchState")
  public static var Aborted(default,never):Const<PStruct<FName>>;

  // !!FIXME!! Remove these once extern baker automatically generates them
  public function ChoosePlayerStart_Implementation(player:AController) : AActor;
  @:thisConst public function MustSpectate_Implementation(NewPlayerController : unreal.APlayerController) : Bool;

  function InitGameState() : Void;
  function PostLogin(NewPlayer:APlayerController) : Void;
  function Logout(Exiting:AController) : Void;
  function SetPlayerDefaults(PlayerPawn:APawn) : Void;

  private function HandleMatchIsWaitingToStart() : Void;
  private function HandleMatchHasStarted() : Void;
  private function HandleMatchHasEnded() : Void;
  private function HandleLeavingMap() : Void;
  private function HandleMatchAborted() : Void;

  function ShouldSpawnAtStartSpot(player:AController) : Bool;

  /*
	private function InitNewPlayer(NewPlayerController:APlayerController,
                                 UniqueId:Const<PRef<TSharedPtr< Const<FUniqueNetId> >>>,
                                 Options:Const<PRef<FString>>,
                                 Portal:Const<PRef<FString>>) : FString;
  */
}
