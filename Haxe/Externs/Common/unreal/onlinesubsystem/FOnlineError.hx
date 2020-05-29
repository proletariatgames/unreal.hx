package unreal.onlinesubsystem;

import unreal.*;

/**
 * Common error results
 */
@:glueCppIncludes("OnlineError.h") @:umodule("OnlineSubsystem")
@:uname("EOnlineErrorResult")
@:class @:uextern @:uenum extern enum EOnlineErrorResult
{
	/** Successful result. no further error processing needed */
	Success;

	/** Failed due to no connection */
	NoConnection;
	/** */
	RequestFailure;
	/** */
	InvalidCreds;
	/** Failed due to invalid or missing user */
	InvalidUser;
	/** Failed due to invalid or missing auth for user */
	InvalidAuth;
	/** Failed due to invalid access */
	AccessDenied;
	/** Throttled due to too many requests */
	TooManyRequests;
	/** Async request was already pending */
	AlreadyPending;
	/** Invalid parameters specified for request */
	InvalidParams;
	/** Data could not be parsed for processing */
	CantParse;
	/** Invalid results returned from the request. Parsed but unexpected results */
	InvalidResults;
	/** Incompatible client for backend version */
	IncompatibleVersion;
	/** Not configured correctly for use */
	NotConfigured;
	/** Feature not available on this implementation */
	NotImplemented;
	/** Interface is missing */
	MissingInterface;
	/** Operation was canceled (likely by user) */
	Canceled;
	/** Extended error. More info can be found in the results or by looking at the ErrorCode */
	FailExtended;

	/** Default state */
	Unknown;
}

@:glueCppIncludes("OnlineError.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class FOnlineError
{

	/** Accessors */
	public function GetErrorResult():EOnlineErrorResult;

	public function GetErrorMessage():Const<PRef<FText>>;

	public function GetErrorRaw():Const<PRef<FString>>;

	public function GetErrorCode():Const<PRef<FString>>;

	public function WasSuccessful():Bool;

}
