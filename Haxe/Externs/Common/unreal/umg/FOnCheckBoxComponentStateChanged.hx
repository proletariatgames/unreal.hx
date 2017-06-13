package unreal.umg;

@:glueCppIncludes("UMG.h", "Components/CheckBox.h")
@:uname('FOnCheckBoxComponentStateChanged')
typedef FOnCheckBoxComponentStateChanged = DynamicMulticastDelegate<FOnCheckBoxComponentStateChanged,Bool->Void>;
