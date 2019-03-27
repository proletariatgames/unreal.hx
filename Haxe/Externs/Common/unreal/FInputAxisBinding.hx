package unreal;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputAxisBinding extends FInputBinding {
	/** The axis mapping being bound to. */
	public var AxisName:FName;

	/**
	 * The delegate bound to the axis.
	 * It will be called each frame that the input component is in the input stack
	 * regardless of whether the value is non-zero or has changed.
	 */
	public var AxisDelegate:FInputAxisUnifiedDelegate;

	/**
	 * The value of the axis as calculated during the most recent UPlayerInput::ProcessInputStack
	 * if the InputComponent was in the stack, otherwise all values should be 0.
	 */
	public var AxisValue:Float32;

  function new(InAxisName:FName);
}