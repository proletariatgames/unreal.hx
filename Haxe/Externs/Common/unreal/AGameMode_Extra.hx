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

  function ReadyToStartMatch_Implementation() : Bool;

  private function SetMatchState(NewState:FName) : Void;

  private function HandleMatchIsWaitingToStart() : Void;
  private function HandleMatchHasStarted() : Void;
  private function HandleMatchHasEnded() : Void;
  private function HandleLeavingMap() : Void;
  private function HandleMatchAborted() : Void;

  /*
     private function InitNewPlayer(NewPlayerController:APlayerController,
     UniqueId:Const<PRef<TSharedPtr< Const<FUniqueNetId> >>>,
     Options:Const<PRef<FString>>,
     Portal:Const<PRef<FString>>) : FString;
   */

  function AddInactivePlayer(PlayerState:APlayerState, PC:APlayerController) : Void;
}
