package unreal;

@:glueCppIncludes("GameFramework/PlayerController.h")
@:noEquals
@:noCopy
@:uextern
extern class FInputModeUIOnly extends FInputModeDataBase {

  @:uname(".ctor")
  public static function create() : FInputModeUIOnly;

  public function SetWidgetToFocus(InWidgetToFocus:TSharedPtr<SWidget>) : FInputModeUIOnly;
}
