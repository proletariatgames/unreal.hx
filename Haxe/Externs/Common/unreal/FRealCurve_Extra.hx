package unreal;

@:noCopy
extern class FRealCurve_Extra
{
	@:thisConst
	public function GetKeyValue(Hande:FKeyHandle) : Float32;

	@:thisConst
	public function Eval(InTime:Float32, InDefaultValue:Float32 = 0.0) : Float32;
}
