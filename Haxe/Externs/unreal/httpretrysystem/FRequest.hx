package unreal.httpretrysystem;

/**
 * class FRequest is what the retry system accepts as inputs
 */
@:glueCppIncludes('HttpRetrySystem.h')
@:uname('FHttpRetrySystem.FRequest')
@:uextern extern class FRequest {
  function new(
      HttpRequest:PRef<TSharedRef<IHttpRequest>>,
      InRetryCountOverride:PRef<TOptionalSetting<FakeUInt32>> /* = Unused() */,
      InRetryTimeoutRelativeSecondsOverride:PRef<TOptionalSetting<Float64>> /* = Unused() */,
      InRetryResponseCodes:PRef<TSet<Int32>>
    );

  function OnProcessRequestComplete():PRef<FOnProcessRequestCompleteDelegate>;
  function GetStatus():EStatus;
}

/**
 * Delegate called when an FRequest completes
 *
 * @param first parameter -  original FRequest
 * @param second parameter - indicates whether or not the request completed successfully
 */
@:glueCppIncludes('HttpRetrySystem.h')
@:uname('FHttpRetrySystem.FRequest.FOnProcessRequestCompleteDelegate')
typedef FOnProcessRequestCompleteDelegate = Delegate<FOnProcessRequestCompleteDelegate,PRef<TSharedRef<FRequest>>->Bool->Void>;
