package unreal;

import unreal.inputcore.ETouchType;
import unreal.inputcore.FKey;


extern class APlayerController_Extra {

  public function InitInputSystem() : Void;
	public function InputKey(Key:FKey, EventType:EInputEvent, AmountDepressed:Float32, bGamepad:Bool) : Bool;
	public function InputTouch(Handle:FakeUInt32, Type:ETouchType, TouchLocation:Const<PRef<FVector2D>>, DeviceTimestamp:FDateTime, TouchpadIndex:FakeUInt32) : Bool;
	public function InputAxis(Key:FKey, Delta:Float32, DeltaTime:Float32, NumSamples:Int32, bGamepad:Bool) : Bool;
	public function InputMotion(Tilt:Const<PRef<FVector>>, RotationRate:Const<PRef<FVector>>, Gravity:Const<PRef<FVector>>, Acceleration:Const<PRef<FVector>>) : Bool;

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
	/**
	 * If bAutoManageActiveCameraTarget is true, then automatically manage the active camera target.
	 * If there a CameraActor placed in the level with an auto-activate player assigned to it, that will be preferred, otherwise SuggestedTarget will be used.
	 */
	public function AutoManageActiveCameraTarget(SuggestedTarget:AActor) : Void;

  public function HasClientLoadedCurrentWorld() : Bool;

  @:thisConst
  public function GetLocalPlayer() : ULocalPlayer;

  public function ConsoleCommand(Command:Const<PRef<FString>>, bWriteToLog:Bool) : FString;

  public function AddCheats (bForce:Bool) : Void;
  public function ClientWasKicked(kickReason:Const<PRef<FText>>):Void;
  public function ClientWasKicked_Implementation(kickReason:Const<PRef<FText>>):Void;

  public function FlushPressedKeys() : Void;

  /** @return true if this controller thinks it's able to restart. Called from GameMode::PlayerCanRestart */
  public function CanRestartPlayer() : Bool;

  public function PreClientTravel(PendingURL:Const<PRef<FString>>, TravelType:ETravelType, bIsSeamlessTravel:Bool):Void;

  public function CleanupPlayerState() : Void;
}
