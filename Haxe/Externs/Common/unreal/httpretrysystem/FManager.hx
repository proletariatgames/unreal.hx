package unreal.httpretrysystem;

@:glueCppIncludes('HttpRetrySystem.h')
@:uname('FHttpRetrySystem.FManager')
@:uextern extern class FManager {
#if (UE_VER >= 4.22)
	function new(
			InRetryLimitCountDefault:Const<PRef<TOptional<UInt32>>>, /* = Unused() */
			InRetryTimeoutRelativeSecondsDefault:Const<PRef<TOptional<Float64>>> /* = Unused() */
		);

	function CreateRequest(
			@:opt(TOptional.createEmpty(new unreal.TypeParam<UInt32>())) ?InRetryLimitCountOverride:Const<PRef<TOptional<UInt32>>>,
			@:opt(TOptional.createEmpty(new unreal.TypeParam<unreal.Float64>())) ?InRetryTimeoutRelativeSecondsOverride:Const<PRef<TOptional<unreal.Float64>>>,
			@:opt(TSet.create(new unreal.TypeParam<unreal.Int32>())) ?InRetryResponseCodes:Const<PRef<TSet<unreal.Int32>>>,
			@:opt(TSet.create(new unreal.TypeParam<unreal.FName>())) ?InRetryVerbs:Const<PRef<TSet<FName>>>
	) : TSharedRef<FRequest>;
#else
	function new(
			InRetryLimitCountDefault:Const<PRef<TOptionalSetting<UInt32>>>, /* = Unused() */
			InRetryTimeoutRelativeSecondsDefault:Const<PRef<TOptionalSetting<Float64>>> /* = Unused() */
		);

	function CreateRequest(
			@:opt(TOptionalSetting.Unused(new unreal.TypeParam<UInt32>())) ?InRetryLimitCountOverride:Const<PRef<TOptionalSetting<UInt32>>>,
			@:opt(TOptionalSetting.Unused(new unreal.TypeParam<unreal.Float64>())) ?InRetryTimeoutRelativeSecondsOverride:Const<PRef<TOptionalSetting<unreal.Float64>>>,
			@:opt(TSet.create(new unreal.TypeParam<unreal.Int32>())) ?InRetryResponseCodes:Const<PRef<TSet<unreal.Int32>>>,
			@:opt(TSet.create(new unreal.TypeParam<unreal.FName>())) ?InRetryVerbs:Const<PRef<TSet<FName>>>
	) : TSharedRef<FRequest>;
#end

	/**
	 * Updates the entries in the list of retry requests.
	 * Optional parameters are for future connection health assessment
	 *
	 **/
	function Update():Bool;

	function SetRandomFailureRate(Value:Float32):Void;
}
