package unreal;


extern class AGameMode_Extra {
  @:global("MatchState")
  public static var EnteringMap(default,never):Const<FName>;
  @:global("MatchState")
  public static var WaitingToStart(default,never):Const<FName>;
  @:global("MatchState")
  public static var InProgress(default,never):Const<FName>;
  @:global("MatchState")
  public static var WaitingPostMatch(default,never):Const<FName>;
  @:global("MatchState")
  public static var LeavingMap(default,never):Const<FName>;
  @:global("MatchState")
  public static var Aborted(default,never):Const<FName>;

  // !!FIXME!! Remove these once extern baker automatically generates them
  public function ChoosePlayerStart_Implementation(player:AController) : AActor;
  @:thisConst public function MustSpectate_Implementation(NewPlayerController : unreal.APlayerController) : Bool;

  function GetDefaultPawnClassForController_Implementation(inController:unreal.AController) : unreal.UClass;
  function PlayerCanRestart_Implementation(Player : unreal.APlayerController) : Bool;
  function InitGameState() : Void;
  function PostLogin(NewPlayer:APlayerController) : Void;
  // /**
  //   Accept or reject a player attempting to join the server.
  //   Fails login if you set the ErrorMessage to a non-empty string.
  //   PreLogin is called before Login. Significant game time may pass before Login is called, especially if content is downloaded.
  //  */
  // function PreLogin(options:Const<PRef<FString>>, address:Const<PRef<FString>>, uniqueId:Const<PRef<TSharedPtr<Const<FUniqueNetId>>>>, errorMessage:PRef<FString>) : Void;

  function Logout(Exiting:AController) : Void;
  function SetPlayerDefaults(PlayerPawn:APawn) : Void;
  /** Does end of game handling for the online layer */
  function RestartPlayer(newPlayer:APlayerController) : Void;
  function PostSeamlessTravel() : Void;
  function GetSeamlessTravelActorList(bToEntry:Bool, actorList:PRef<TArray<AActor>>) : Void;

  private function SetMatchState(NewState:FName) : Void;

  private function HandleMatchIsWaitingToStart() : Void;
  private function HandleMatchHasStarted() : Void;
  private function HandleMatchHasEnded() : Void;
  private function HandleLeavingMap() : Void;
  private function HandleMatchAborted() : Void;

  function ShouldSpawnAtStartSpot(player:AController) : Bool;

  function AllowCheats(P:APlayerController) : Bool;

  /*
     private function InitNewPlayer(NewPlayerController:APlayerController,
     UniqueId:Const<PRef<TSharedPtr< Const<FUniqueNetId> >>>,
     Options:Const<PRef<FString>>,
     Portal:Const<PRef<FString>>) : FString;
   */
}
