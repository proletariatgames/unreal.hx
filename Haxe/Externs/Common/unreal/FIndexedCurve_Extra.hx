package unreal;

@:noCopy
extern class FIndexedCurve_Extra
{
	@:thisConst
	public function GetNumKeys() : Int32;

	@:thisConst
	public function GetKeyTime(Handle:FKeyHandle) : Float32;

	@:thisConst
	public function GetFirstKeyHandle() : FKeyHandle;

	@:thisConst
	public function GetLastKeyHandle() : FKeyHandle;

	@:thisConst
	public function GetNextKey(Handle:FKeyHandle) : FKeyHandle;

	@:thisConst
	public function GetPreviousKey(Handle:FKeyHandle) : FKeyHandle;
}
