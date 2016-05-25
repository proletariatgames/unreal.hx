package unreal;

@:glueCppIncludes("GameFramework/PlayerController.h")
@:noEquals
@:noCopy
@:uextern
extern class FInputModeGameOnly extends FInputModeDataBase {

  @:uname(".ctor")
  public static function create() : FInputModeGameOnly;

}
