package unreal.umg;

@:glueCppIncludes('Button.h')
@:uname('FOnButtonClickedEvent')
typedef FOnButtonClickedEvent = DynamicMulticastDelegate<FOnButtonClickedEvent,Void->Void>;
