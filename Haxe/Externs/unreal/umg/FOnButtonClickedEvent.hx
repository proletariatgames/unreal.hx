package unreal.umg;

@:glueCppIncludes("UMG.h", "Components/ContentWidget.h", "Components/Button.h")
@:uname('FOnButtonClickedEvent')
typedef FOnButtonClickedEvent = DynamicMulticastDelegate<FOnButtonClickedEvent,Void->Void>;
