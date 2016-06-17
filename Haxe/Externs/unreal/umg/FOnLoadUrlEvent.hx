package unreal.umg;

// Note: Boolean return value for the delegate function indicates "should load content," i.e. return false to load
// the Url as normal and false to prevent loading of the Url.

@:glueCppIncludes("UMG.h", "WebBrowser.h")
@:uname('UWebBrowser.FOnLoadUrlEvent')
@:uParamName('Method') @:uParamName('Url') @:uParamName('OutBody')
typedef FOnLoadUrlEvent = DynamicDelegate<FOnLoadUrlEvent,Const<PRef<FString>>->Const<PRef<FString>>->PRef<FString>->Bool>;
