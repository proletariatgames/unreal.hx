package unreal.umg;

@:glueCppIncludes("UMG.h", "Components/ContentWidget.h", "Components/Button.h")
@:uname('FOnButtonHoverEvent')
typedef FOnButtonHoverEvent = DynamicMulticastDelegate<FOnButtonHoverEvent,Void->Void>;
