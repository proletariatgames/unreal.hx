package unreal;

@:glueCppIncludes("Engine.h")
@:uextern extern class APlayerController extends AController {

  //function SetupInputComponent() : Void;

  @:thisConst
  public function IsMoveInputIgnored() : Bool;

  @:thisConst
  public function IsLookInputIgnored() : Bool;

  public function InitInputSystem() : Void;

  public function GetNextViewablePlayer(dir:Int32) : APlayerState;

	/** UPlayer associated with this PlayerController.  Could be a local player or a net connection. */
	@:uproperty()
	public var Player : UPlayer;

	/** Object that manages player input. */
	@:uproperty(transient)
	public var PlayerInput : UPlayerInput;

}
