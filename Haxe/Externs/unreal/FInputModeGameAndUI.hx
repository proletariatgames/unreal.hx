package unreal;

@:glueCppIncludes("GameFramework/PlayerController.h")
@:noEquals
@:noCopy
@:uextern
extern class FInputModeGameAndUI extends FInputModeDataBase {

  @:uname(".ctor")
  public static function create() : FInputModeGameAndUI;

}
