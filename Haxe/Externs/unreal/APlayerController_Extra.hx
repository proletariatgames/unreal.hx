package unreal;

extern class APlayerController_Extra {

  public function InitInputSystem() : Void;

  public function GetNextViewablePlayer(dir:Int32) : APlayerState;

  public function SetInputMode (InData:Const<PRef<FInputModeDataBase>>) : Void;
}
