package unreal.umg;

@:glueCppIncludes("UMG.h", "WebBrowser.h")
@:uname('UWebBrowser.FOnUrlChangedEvent')
typedef FOnUrlChangedEvent = DynamicMulticastDelegate<FOnUrlChangedEvent,Const<PRef<FText>>->Void>;
