package unreal.umg;

@:glueCppIncludes("UMG.h", "Components/ContentWidget.h", "Components/Slider.h")
extern class USlider_Extra {
  public var OnValueChanged : FOnFloatValueChangedEvent;
}
