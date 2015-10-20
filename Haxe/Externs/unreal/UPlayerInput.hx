package unreal;

/** 
 * Defines a mapping between an axis and key 
 * 
 * @see https://docs.unrealengine.com/latest/INT/Gameplay/Input/index.html
**/
@:glueCppIncludes("GameFramework/PlayerInput.h")
@:uextern extern class FInputAxisKeyMapping {
	/** Friendly name of axis, e.g "MoveForward" */
	@:uproperty(EditAnywhere, Category="Input")
	public var AxisName : PStruct<FName>;

	/** Multiplier to use for the mapping when accumulating the axis value */
	@:uproperty(EditAnywhere, Category="Input")
	public var Scale : Float32;
}

@:glueCppIncludes("GameFramework/PlayerInput.h")
@:uextern extern class UPlayerInput extends UObject {

	/** This player's version of Axis Mappings */
	public var AxisMappings : TArray<PStruct<FInputAxisKeyMapping>>;

	/** Clear the current cached key maps and rebuild from the source arrays. */
	public function ForceRebuildingKeyMaps(bRestoreDefaults:Bool = false) : Void;

}
