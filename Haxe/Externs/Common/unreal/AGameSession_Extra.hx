package unreal;

extern class AGameSession_Extra
{
  public function HandleStartMatchRequest() : Bool;
  public function HandleMatchIsWaitingToStart() : Void;
  public function HandleMatchHasStarted() : Void;
  public function HandleMatchHasEnded() : Void;
  public function KickPlayer(kickerPlayer:APlayerController, kickReason:Const<PRef<FText>>):Bool;
}
