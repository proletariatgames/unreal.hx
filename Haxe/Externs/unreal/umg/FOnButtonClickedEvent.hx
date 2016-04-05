package unreal.umg;

@:glueCppIncludes('Button.h')
@:uname('FOnButtonClickedEvent')
@:uextern extern class FOnButtonClickedEvent extends DynamicMulticastDelegate<Void->Void> {}