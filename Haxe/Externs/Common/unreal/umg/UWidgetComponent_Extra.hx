package unreal.umg;

@:glueCppIncludes("Components/WidgetComponent.h")
extern class UWidgetComponent_Extra {
  public function SetWidgetClass(InWidgetClass:TSubclassOf<UUserWidget>) : Void;
  public function SetWidgetSpace(NewSpace:EWidgetSpace) : Void;
  public function SetPivot(InPivot:Const<PRef<FVector2D>>) : Void;
}