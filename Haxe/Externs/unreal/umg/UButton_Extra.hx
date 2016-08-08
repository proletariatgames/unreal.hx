package unreal.umg;

@:glueCppIncludes("UMG.h", "Components/ContentWidget.h", "Components/Button.h")
extern class UButton_Extra {
  public var OnClicked : FOnButtonClickedEvent;
  public var OnHovered : FOnButtonHoverEvent;
  public var OnUnhovered : FOnButtonHoverEvent;
}
