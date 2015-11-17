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

  @:thisConst public function MustSpectate_Implementation(NewPlayerController : unreal.APlayerController) : Bool;

  /*
	private function InitNewPlayer(NewPlayerController:APlayerController,
                                 UniqueId:Const<PRef<TSharedPtr< Const<FUniqueNetId> >>>,
                                 Options:Const<PRef<FString>>,
                                 Portal:Const<PRef<FString>>) : FString;
  */
}
