package unreal;

@:glueCppIncludes("IHttpRequest.h")
@:uname("EHttpRequestStatus.Type")
@:uextern extern enum EHttpRequestStatus {
  NotStarted;
  Processing;
  Failed;
  Failed_ConnectionError;
  Succeeded;
}

@:glueCppIncludes("IHttpRequest.h")
@:uname('FHttpRequestCompleteDelegate')
typedef FHttpRequestCompleteDelegate = Delegate<FHttpRequestCompleteDelegate, TSharedPtr<IHttpRequest>->TThreadSafeSharedPtr<IHttpResponse>->Bool->Void>;

@:glueCppIncludes("IHttpRequest.h")
@:uname('FHttpRequestProgressDelegate')
typedef FHttpRequestProgressDelegate = Delegate<FHttpRequestProgressDelegate, TSharedPtr<IHttpRequest>->Int->Int->Void>;

@:glueCppIncludes("IHttpRequest.h")
@:noCopy @:noEquals @:noClass @:uextern extern class IHttpRequest extends IHttpBase
{
  function GetVerb() : FString;
  function SetVerb(Verb:Const<PRef<FString>>) : Void;
  function SetURL(URL:Const<PRef<FString>>) : Void;
  function SetContent(ContentPayload:Const<PRef<TArray<UInt8>>>) : Void;
  function SetContentAsString(ContentString:Const<PRef<FString>>) : Void;
  function SetHeader(HeaderName:Const<PRef<FString>>, HeaderValue:Const<PRef<FString>>) : Void;
  function ProcessRequest() : Bool;
  function OnProcessRequestComplete() : PRef<FHttpRequestCompleteDelegate>;
  function OnRequestProgress() : PRef<FHttpRequestProgressDelegate>;
  function CancelRequest() : Void;
  function GetStatus() : EHttpRequestStatus;
  function GetResponse() : TThreadSafeSharedPtr<IHttpResponse>;
  function Tick(DeltaSeconds:Float32) : Void;
  function GetElapsedTime() : Float32;
}
