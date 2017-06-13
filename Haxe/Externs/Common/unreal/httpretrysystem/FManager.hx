package unreal.httpretrysystem;

@:glueCppIncludes('HttpRetrySystem.h')
@:uname('FHttpRetrySystem.FManager')
@:uextern extern class FManager {
  function new(
      InRetryLimitCountDefault:Const<PRef<TOptionalSetting<FakeUInt32>>>, /* = Unused() */
      InRetryTimeoutRelativeSecondsDefault:Const<PRef<TOptionalSetting<Float64>>> /* = Unused() */
    );

  function CreateRequest(
    InRetryLimitCountOverride : Const<PRef<TOptionalSetting<FakeUInt32>>>,
    InRetryTimeoutRelativeSecondsOverride : Const<PRef<TOptionalSetting<Float64>>>,
    InRetryResponseCodes:Const<PRef<TSet<Int32>>>
  ) : TSharedRef<FRequest>;

  /**
   * Updates the entries in the list of retry requests.
   * Optional parameters are for future connection health assessment
   *
   **/
  function Update():Bool;

  function SetRandomFailureRate(Value:Float32):Void;
}
