package unreal.umg;

@:glueCppIncludes("UMG.h", "Components/ContentWidget.h", "Components/Slider.h")
@:uname('FOnFloatValueChangedEvent')
typedef FOnFloatValueChangedEvent = DynamicMulticastDelegate<FOnFloatValueChangedEvent,unreal.Float32->Void>;
