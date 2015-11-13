package unreal;

@:glueCppIncludes("GameFramework/PlayerController.h")
@:uextern
extern class FInputModeUIOnly extends FInputModeDataBase {
  public function SetWidgetToFocus(InWidgetToFocus:TSharedPtr<SWidget>) : FInputModeUIOnly;
}
