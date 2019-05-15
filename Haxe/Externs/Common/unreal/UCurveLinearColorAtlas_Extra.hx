package unreal;

extern class UCurveLinearColorAtlas_Extra {
   @:ureplace @:ufunction(BlueprintCallable) @:final public function GetCurvePosition(InCurve : unreal.UCurveLinearColor, Position : Ref<unreal.Float32>) : Bool;

	 public function GetCurveIndex(InCurve : unreal.UCurveLinearColor, Index : Ref<unreal.Int32>) : Bool;
}
