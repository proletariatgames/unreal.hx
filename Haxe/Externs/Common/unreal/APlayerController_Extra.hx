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

	public function PawnLeavingGame() : Void;

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
  public function ClientWasKicked_Implementation(kickReason:Const<PRef<FText>>):Void;

  public function FlushPressedKeys() : Void;

  /** @return true if this controller thinks it's able to restart. Called from GameMode::PlayerCanRestart */
  public function CanRestartPlayer() : Bool;

  public function PreClientTravel(PendingURL:Const<PRef<FString>>, TravelType:ETravelType, bIsSeamlessTravel:Bool):Void;

  public function CleanupPlayerState() : Void;

  public function SetPawn(InPawn:APawn) : Void;

  /** Returns the first of GetPawn() or GetSpectatorPawn() that is not nullptr, or nullptr otherwise. */
  @:thisConst
	public function GetPawnOrSpectator() : APawn;
  /**
    Retrieves the X and Y screen coordinates of the mouse cursor. Returns false if there is no associated mouse device
  **/
  @:ureplace @:ufunction(BlueprintCallable) @:thisConst @:final public function GetMousePosition(LocationX : Ref<unreal.Float32>, LocationY : Ref<unreal.Float32>) : Bool;

  /**
    Helper to get the size of the HUD canvas for this player controller.  Returns 0 if there is no HUD
  **/
  @:ureplace @:ufunction(BlueprintCallable) @:thisConst @:final public function GetViewportSize(SizeX : Ref<unreal.Int32>, SizeY : Ref<unreal.Int32>) : Void;

	/**
	 * Mutes a remote player on the server and then tells the client to mute
	 *
	 * @param PlayerNetId the remote player to mute
	 */
	public function GameplayMutePlayer(PlayerNetId : Const<PRef<FUniqueNetIdRepl>>) : Void;

	/**
	 * Unmutes a remote player on the server and then tells the client to unmute
	 *
	 * @param PlayerNetId the remote player to unmute
	 */
	public function GameplayUnmutePlayer(PlayerNetId : Const<PRef<FUniqueNetIdRepl>>) : Void;

	/**
	 * Is the specified player muted by this controlling player
	 * for any reason (gameplay, system, etc), check voice interface IsMuted() for system mutes
	 *
	 * @param PlayerId potentially muted player
	 * @return true if player is muted, false otherwise
	 */
	public function IsPlayerMuted(PlayerId : Const<PRef<FUniqueNetId>>) : Bool;
}
