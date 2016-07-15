package unreal.httpretrysystem;

@:glueCppIncludes('HttpRetrySystem.h')
@:uname("FHttpRetrySystem.FRequest.EStatus.Type")
@:uextern extern enum EStatus {
  NotStarted;
  Processing;
  ProcessingLockout;
  Cancelled;
  FailedRetry;
  FailedTimeout;
  Succeeded;
}
