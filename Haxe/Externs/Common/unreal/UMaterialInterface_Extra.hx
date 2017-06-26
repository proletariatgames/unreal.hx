package unreal;

extern class UMaterialInterface_Extra {
	@:thisConst
	function GetOpacityMaskClipValue() : Float32;
	@:thisConst
	function GetBlendMode() : EBlendMode;
	@:thisConst
	function GetShadingModel() : EMaterialShadingModel;
	@:thisConst
	function IsTwoSided() : Bool;
	@:thisConst
	function IsDitheredLODTransition() : Bool;
	@:thisConst
	function IsMasked() : Bool;
}
