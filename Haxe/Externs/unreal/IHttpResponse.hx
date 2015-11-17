package unreal;

@:glueCppIncludes("IHttpResponse.h")
@:uname("EHttpResponseCodes.Type")
@:uextern extern enum EHttpResponseCodes
{
  Unknown;
  Continue;
  SwitchProtocol;
  Ok;
  Created;
  Accepted;
  Partial;
  NoContent;
  ResetContent;
  PartialContent;
  Ambiguous;
  Moved;
  Redirect;
  RedirectMethod;
  NotModified;
  UseProxy;
  RedirectKeepVerb;
  BadRequest;
  Denied;
  PaymentReq;
  Forbidden;
  NotFound;
  BadMethod;
  NoneAcceptable;
  ProxyAuthReq;
  RequestTimeout;
  Conflict;
  Gone;
  LengthRequired;
  PrecondFailed;
  RequestTooLarge;
  UriTooLong;
  UnsupportedMedia;
  RetryWith;
  ServerError;
  NotSupported;
  BadGateway;
  ServiceUnavail;
  GatewayTimeout;
  VersionNotSup;
}

@:glueCppIncludes("IHttpResponse.h")
@:noCopy @:noEquals @:noClass @:uextern extern class IHttpResponse extends IHttpBase
{
  @:global @:uname("EHttpResponseCodes::IsOk")
  static function IsOk(code:Int) : Bool;

  function GetResponseCode() : Int;
  function GetContentAsString() : FString;
}
