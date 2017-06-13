package unreal;

extern class UKismetMaterialLibrary_Extra {

	/** Sets a scalar parameter value on the material collection instance. Logs if ParameterName is invalid. */
	static function SetScalarParameterValue(WorldContextObject:UObject, Collection:UMaterialParameterCollection, ParameterName:FName, ParameterValue:Float32) : Void;

	/** Sets a vector parameter value on the material collection instance. Logs if ParameterName is invalid. */
	static function SetVectorParameterValue(WorldContextObject:UObject, Collection:UMaterialParameterCollection, ParameterName:FName, ParameterValue:Const<PRef<FLinearColor>>) : Void;

	/** Gets a scalar parameter value from the material collection instance. Logs if ParameterName is invalid. */
	static function GetScalarParameterValue(WorldContextObject:UObject, Collection:UMaterialParameterCollection, ParameterName:FName) : Float32;

	/** Gets a vector parameter value from the material collection instance. Logs if ParameterName is invalid. */
	static function GetVectorParameterValue(WorldContextObject:UObject, Collection:UMaterialParameterCollection, ParameterName:FName) : FLinearColor;

	/** Creates a Dynamic Material Instance which you can modify during gameplay. */
	static function CreateDynamicMaterialInstance(WorldContextObject:UObject, Parent:UMaterialInterface) : UMaterialInstanceDynamic;
}