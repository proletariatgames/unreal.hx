package unreal;

extern class APlayerController_Extra {

  public function InitInputSystem() : Void;

  public function GetNextViewablePlayer(dir:Int32) : APlayerState;

  public function SetPause(bPause:Bool) : Bool;

  public function StartTalking() : Void;
  public function StopTalking() : Void;

  @:thisConst public function GetSpawnLocation() : FVector;
  public function SetInputMode (InData:Const<PRef<FInputModeDataBase>>) : Void;

  private function BeginPlayingState() : Void;
  private function EndPlayingState() : Void;
  private function SetupInputComponent() : Void;

	/** Set the view target
	 * @param A - new actor to set as view target
   */
	public function SetViewTarget(NewViewTarget:AActor, TransitionParams:FViewTargetTransitionParams) : Void;

  @:thisConst
  public function GetLocalPlayer() : ULocalPlayer;

  public function ConsoleCommand(Command:Const<PRef<FString>>, bWriteToLog:Bool) : FString;

  public function AddCheats (bForce:Bool) : Void;
  public function ClientWasKicked(kickReason:Const<PRef<FText>>):Void;
  public function ClientWasKicked_Implementation(kickReason:Const<PRef<FText>>):Void;

  public function FlushPressedKeys() : Void;
}
