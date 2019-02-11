package unreal;

extern class AGameModeBase_Extra {
  /** Whether players should immediately spawn when logging in, or stay as spectators until they manually spawn */
	private var bStartPlayersAsSpectators : Bool;

  /** Whether the game is pauseable. */
  private var bPauseable : Bool;

  private function ShouldSpawnAtStartSpot(player:AController) : Bool;

  /**
    * Accept or reject a player attempting to join the server.  Fails login if you set the ErrorMessage to a non-empty string.
    * PreLogin is called before Login.  Significant game time may pass before Login is called
    *
    * @param	Options					The URL options (e.g. name/spectator) the player has passed
    * @param	Address					The network address of the player
    * @param	UniqueId				The unique id the player has passed to the server
    * @param	ErrorMessage			When set to a non-empty value, the player will be rejected using the error message set
    */
  function PreLogin(Options:Const<PRef<FString>>, Address:Const<PRef<FString>>, UniqueId:Const<PRef<FUniqueNetIdRepl>>, ErrorMessage:PRef<FString>) : Void;
  /**
    * Customize incoming player based on URL options
    *
    * @param NewPlayerController player logging in
    * @param UniqueId unique id for this player
    * @param Options URL options that came at login
    *
    */
  private function InitNewPlayer(NewPlayerController:APlayerController, UniqueId:Const<PRef<FUniqueNetIdRepl>>, Options:Const<PRef<FString>>, Portal:Const<PRef<FString>>) : FString;

  function InitGameState() : Void;
  function PostLogin(NewPlayer:APlayerController) : Void;
  function Logout(Exiting:AController) : Void;
  function SetPlayerDefaults(PlayerPawn:APawn) : Void;
  private function InitSeamlessTravelPlayer(Controller:AController) : Void;
  function PostSeamlessTravel() : Void;
  function GetSeamlessTravelActorList(bToEntry:Bool, actorList:PRef<TArray<AActor>>) : Void;
  function AllowCheats(P:APlayerController) : Bool;

  // !!FIXME!! Remove these once extern baker automatically generates them
  function PlayerCanRestart_Implementation(Player : unreal.APlayerController) : Bool;
  function ChoosePlayerStart_Implementation(player:AController) : AActor;
  function GetDefaultPawnClassForController_Implementation(inController:unreal.AController) : unreal.UClass;
  function HandleStartingNewPlayer_Implementation(NewPlayer:unreal.APlayerController) : Void;
  @:thisConst public function MustSpectate_Implementation(NewPlayerController : unreal.APlayerController) : Bool;

}