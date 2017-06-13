package unreal.umg;

@:glueCppIncludes("UMG.h", "Widget.h")
@:uname('UWidget.FGetText')
typedef FGetText = DynamicDelegate<FGetText,Void->FText>;
