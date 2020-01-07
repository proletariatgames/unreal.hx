package unreal.umg;

@:glueCppIncludes("Components/WidgetComponent.h")
extern class UWidgetComponent_Extra {
  public function SetWidgetClass(InWidgetClass:TSubclassOf<UUserWidget>) : Void;
}