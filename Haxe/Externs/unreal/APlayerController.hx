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

}
