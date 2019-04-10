package unreal;


extern class UMaterialParameterCollectionInstance_Extra {
	/** Sets scalar parameter value overrides, returns false if the parameter was not found. */
	public function SetScalarParameterValue(ParameterName:FName, ParameterValue:Float32):Bool;
	/** Sets vector parameter value overrides, returns false if the parameter was not found. */
	public function SetVectorParameterValue(ParameterName:FName, ParameterValue:Const<PRef<FLinearColor>>):Bool;
	@:thisConst
	function GetScalarParameterValue(ParameterName:FName, OutParameterValue:Ref<Float32>) : Bool;
	@:thisConst
	function GetVectorParameterValue(ParameterName:FName, OutParameterValue:PRef<FLinearColor>) : Bool;
}