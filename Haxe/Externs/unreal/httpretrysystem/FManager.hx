package unreal.httpretrysystem;

@:glueCppIncludes('HttpRetrySystem.h')
@:uname('FHttpRetrySystem.FManager')
@:uextern extern class FManager {
  function new(
      InRetryLimitCountDefault:PRef<TOptionalSetting<FakeUInt32>>, /* = Unused() */
      InRetryTimeoutRelativeSecondsDefault:PRef<TOptionalSetting<Float64>>, /* = Unused() */
      InRetryResponseCodesDefault:PRef<TSet<Int32>>
    );


  /**
   * Updates the entries in the list of retry requests.
   * Optional parameters are for future connection health assessment
   *
   **/
  function Update():Bool;

  function ProcessRequest(HttpRequest:PRef<TSharedRef<FRequest>>):Bool;
  function CancelRequest(HttpRequest:PRef<TSharedRef<FRequest>>):Void;

  function SetRandomFailureRate(Value:Float32):Void;
}
