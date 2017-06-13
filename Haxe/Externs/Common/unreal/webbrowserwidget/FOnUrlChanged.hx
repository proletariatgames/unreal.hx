package unreal.webbrowserwidget;

@:glueCppIncludes("UMG.h", "WebBrowser.h")
@:uname('UWebBrowser.FOnUrlChanged')
typedef FOnUrlChanged = DynamicMulticastDelegate<FOnUrlChanged,Const<PRef<FText>>->Void>;
