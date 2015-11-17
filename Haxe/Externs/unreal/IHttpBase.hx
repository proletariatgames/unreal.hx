package unreal;

@:glueCppIncludes("IHttpBase.h")
@:uextern @:noCopy @:noClass @:noEquals extern class IHttpBase
{
  function GetURL() : FString;
  function GetURLParameter(ParameterName:Const<PRef<FString>>) : FString;
  function GetHeader(HeaderName:Const<PRef<FString>>) : FString;
  function GetAllHeaders() : TArray<FString>;
  function GetContent() : Const<PRef<TArray<UInt8>>>;
  function GetContentType() : FString;
  function GetContentLength() : Int;
}
