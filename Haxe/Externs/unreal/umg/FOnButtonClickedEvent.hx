package unreal.umg;

@:glueCppIncludes('Button.h')
typedef FOnButtonClickedEvent = DynamicMulticastDelegate<'FOnButtonClickedEvent',Void->Void>;
