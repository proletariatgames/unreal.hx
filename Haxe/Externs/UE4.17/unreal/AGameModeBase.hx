/**
 * 
 * WARNING! This file was autogenerated by: 
 *  _   _ _   _ __   __ 
 * | | | | | | |\ \ / / 
 * | | | | |_| | \ V /  
 * | | | |  _  | /   \  
 * | |_| | | | |/ /^\ \ 
 *  \___/\_| |_/\/   \/ 
 * 
 * This file was autogenerated by UnrealHxGenerator using UHT definitions.
 * It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
 * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal;

/**
  The GameModeBase defines the game being played. It governs the game rules, scoring, what actors
  are allowed to exist in this game type, and who may enter the game.
  
  It is only instanced on the server and will never exist on the client.
  
  A GameModeBase actor is instantiated when the level is initialized for gameplay in
  C++ UGameEngine::LoadMap().
  
  The class of this GameMode actor is determined by (in order) either the URL ?game=xxx,
  the GameMode Override value set in the World Settings, or the DefaultGameMode entry set
  in the game's Project Settings.
  
  @see https://docs.unrealengine.com/latest/INT/Gameplay/Framework/GameMode/index.html
**/
@:glueCppIncludes("GameFramework/GameModeBase.h")
@:uextern @:uclass extern class AGameModeBase extends unreal.AInfo {
  
  /**
    Whether the game perform map travels using SeamlessTravel() which loads in the background and doesn't disconnect clients
  **/
  @:uproperty public var bUseSeamlessTravel : Bool;
  
  /**
    The default player name assigned to players that join with no name specified.
  **/
  @:uproperty public var DefaultPlayerName : unreal.FText;
  
  /**
    GameState is used to replicate game state relevant properties to all clients.
  **/
  @:uproperty public var GameState : unreal.AGameStateBase;
  
  /**
    Game Session handles login approval, arbitration, online game interface
  **/
  @:uproperty public var GameSession : unreal.AGameSession;
  
  /**
    The PlayerController class used when spectating a network replay.
  **/
  @:uproperty public var ReplaySpectatorPlayerControllerClass : unreal.TSubclassOf<unreal.APlayerController>;
  
  /**
    The pawn class used by the PlayerController for players when spectating.
  **/
  @:uproperty public var SpectatorClass : unreal.TSubclassOf<unreal.ASpectatorPawn>;
  
  /**
    The default pawn class used by players.
  **/
  @:uproperty public var DefaultPawnClass : unreal.TSubclassOf<unreal.APawn>;
  
  /**
    HUD class this game uses.
  **/
  @:uproperty public var HUDClass : unreal.TSubclassOf<unreal.AHUD>;
  
  /**
    A PlayerState of this class will be associated with every player to replicate relevant player information to all clients.
  **/
  @:uproperty public var PlayerStateClass : unreal.TSubclassOf<unreal.APlayerState>;
  
  /**
    The class of PlayerController to spawn for players logging in.
  **/
  @:uproperty public var PlayerControllerClass : unreal.TSubclassOf<unreal.APlayerController>;
  
  /**
    Class of GameState associated with this GameMode.
  **/
  @:uproperty public var GameStateClass : unreal.TSubclassOf<unreal.AGameStateBase>;
  
  /**
    Class of GameSession, which handles login approval and online game interface
  **/
  @:uproperty public var GameSessionClass : unreal.TSubclassOf<unreal.AGameSession>;
  
  /**
    Save options string and parse it when needed
  **/
  @:uproperty public var OptionsString : unreal.FString;
  
  /**
    Returns default pawn class for given controller
  **/
  @:ufunction(BlueprintNativeEvent) public function GetDefaultPawnClassForController(InController : unreal.AController) : unreal.UClass;
  
  /**
    Returns number of active human players, excluding spectators
  **/
  @:ufunction(BlueprintCallable) public function GetNumPlayers() : unreal.Int32;
  
  /**
    Returns number of human players currently spectating
  **/
  @:ufunction(BlueprintCallable) public function GetNumSpectators() : unreal.Int32;
  
  /**
    Transitions to calls BeginPlay on actors.
  **/
  @:ufunction(BlueprintCallable) public function StartPlay() : Void;
  
  /**
    Returns true if the match start callbacks have been called
  **/
  @:ufunction(BlueprintCallable) @:thisConst public function HasMatchStarted() : Bool;
  
  /**
    Overridable function to determine whether an Actor should have Reset called when the game has Reset called on it.
    Default implementation returns true
    @param ActorToReset The actor to make a determination for
    @return true if ActorToReset should have Reset() called on it while restarting the game,
                    false if the GameMode will manually reset it or if the actor does not need to be reset
  **/
  @:ufunction(BlueprintNativeEvent) public function ShouldReset(ActorToReset : unreal.AActor) : Bool;
  
  /**
    Overridable function called when resetting level. This is used to reset the game state while staying in the same map
    Default implementation calls Reset() on all actors except GameMode and Controllers
  **/
  @:ufunction(BlueprintCallable) public function ResetLevel() : Void;
  
  /**
    Return to main menu, and disconnect any players
  **/
  @:ufunction(BlueprintCallable) public function ReturnToMainMenuHost() : Void;
  
  /**
    Notification that a player has successfully logged in, and has been given a player controller
  **/
  @:ufunction(BlueprintImplementableEvent) public function K2_PostLogin(NewPlayer : unreal.APlayerController) : Void;
  
  /**
    Implementable event when a Controller with a PlayerState leaves the game.
  **/
  @:ufunction(BlueprintImplementableEvent) public function K2_OnLogout(ExitingController : unreal.AController) : Void;
  
  /**
    Signals that a player is ready to enter the game, which may start it up
  **/
  @:ufunction(BlueprintNativeEvent) public function HandleStartingNewPlayer(NewPlayer : unreal.APlayerController) : Void;
  
  /**
    Returns true if NewPlayerController may only join the server as a spectator.
  **/
  @:ufunction(BlueprintNativeEvent) @:thisConst public function MustSpectate(NewPlayerController : unreal.APlayerController) : Bool;
  
  /**
    Return whether Viewer is allowed to spectate from the point of view of ViewTarget.
  **/
  @:ufunction(BlueprintNativeEvent) public function CanSpectate(Viewer : unreal.APlayerController, ViewTarget : unreal.APlayerState) : Bool;
  
  /**
    Sets the name for a controller
    @param Controller    The controller of the player to change the name of
    @param NewName               The name to set the player to
    @param bNameChange   Whether the name is changing or if this is the first time it has been set
  **/
  @:ufunction(BlueprintCallable) public function ChangeName(Controller : unreal.AController, NewName : unreal.FString, bNameChange : Bool) : Void;
  
  /**
    Overridable event for GameMode blueprint to respond to a change name call
    @param Controller    The controller of the player to change the name of
    @param NewName               The name to set the player to
    @param bNameChange   Whether the name is changing or if this is the first time it has been set
  **/
  @:ufunction(BlueprintImplementableEvent) public function K2_OnChangeName(Other : unreal.AController, NewName : unreal.FString, bNameChange : Bool) : Void;
  
  /**
    Return the 'best' player start for this player to spawn from
    Default implementation looks for a random unoccupied spot
    
    @param Player is the controller for whom we are choosing a playerstart
    @returns AActor chosen as player start (usually a PlayerStart)
  **/
  @:ufunction(BlueprintNativeEvent) public function ChoosePlayerStart(Player : unreal.AController) : unreal.AActor;
  
  /**
    Return the specific player start actor that should be used for the next spawn
    This will either use a previously saved startactor, or calls ChoosePlayerStart
    
    @param Player The AController for whom we are choosing a Player Start
    @param IncomingName Specifies the tag of a Player Start to use
    @returns Actor chosen as player start (usually a PlayerStart)
  **/
  @:ufunction(BlueprintNativeEvent) public function FindPlayerStart(Player : unreal.AController, IncomingName : unreal.FString) : unreal.AActor;
  
  /**
    Return the specific player start actor that should be used for the next spawn
    This will either use a previously saved startactor, or calls ChoosePlayerStart
    
    @param Player The AController for whom we are choosing a Player Start
    @param IncomingName Specifies the tag of a Player Start to use
    @returns Actor chosen as player start (usually a PlayerStart)
  **/
  @:ufunction(BlueprintCallable) @:final public function K2_FindPlayerStart(Player : unreal.AController, IncomingName : unreal.FString) : unreal.AActor;
  
  /**
    Returns true if it's valid to call RestartPlayer. By default will call Player->CanRestartPlayer
  **/
  @:ufunction(BlueprintNativeEvent) public function PlayerCanRestart(Player : unreal.APlayerController) : Bool;
  
  /**
    Tries to spawn the player's pawn, at the location returned by FindPlayerStart
  **/
  @:ufunction(BlueprintCallable) public function RestartPlayer(NewPlayer : unreal.AController) : Void;
  
  /**
    Tries to spawn the player's pawn at the specified actor's location
  **/
  @:ufunction(BlueprintCallable) public function RestartPlayerAtPlayerStart(NewPlayer : unreal.AController, StartSpot : unreal.AActor) : Void;
  
  /**
    Tries to spawn the player's pawn at a specific location
  **/
  @:ufunction(BlueprintCallable) public function RestartPlayerAtTransform(NewPlayer : unreal.AController, SpawnTransform : unreal.Const<unreal.PRef<unreal.FTransform>>) : Void;
  
  /**
    Called during RestartPlayer to actually spawn the player's pawn, when using a start spot
    @param       NewPlayer - Controller for whom this pawn is spawned
    @param       StartSpot - Actor at which to spawn pawn
    @return      a pawn of the default pawn class
  **/
  @:ufunction(BlueprintNativeEvent) public function SpawnDefaultPawnFor(NewPlayer : unreal.AController, StartSpot : unreal.AActor) : unreal.APawn;
  
  /**
    Called during RestartPlayer to actually spawn the player's pawn, when using a transform
    @param       NewPlayer - Controller for whom this pawn is spawned
    @param       StartSpot - Actor at which to spawn pawn
    @return      a pawn of the default pawn class
  **/
  @:ufunction(BlueprintNativeEvent) public function SpawnDefaultPawnAtTransform(NewPlayer : unreal.AController, SpawnTransform : unreal.Const<unreal.PRef<unreal.FTransform>>) : unreal.APawn;
  
  /**
    Called from RestartPlayerAtPlayerStart, can be used to initialize the start spawn actor
  **/
  @:ufunction(BlueprintNativeEvent) public function InitStartSpot(StartSpot : unreal.AActor, NewPlayer : unreal.AController) : Void;
  
  /**
    Implementable event called at the end of RestartPlayer
  **/
  @:ufunction(BlueprintImplementableEvent) public function K2_OnRestartPlayer(NewPlayer : unreal.AController) : Void;
  
  /**
    Initialize the AHUD object for a player. Games can override this to do something different
  **/
  @:ufunction(BlueprintNativeEvent) private function InitializeHUDForPlayer(NewPlayer : unreal.APlayerController) : Void;
  
  /**
    Called when a PlayerController is swapped to a new one during seamless travel
  **/
  @:ufunction(BlueprintImplementableEvent) private function K2_OnSwapPlayerControllers(OldPC : unreal.APlayerController, NewPC : unreal.APlayerController) : Void;
  
}