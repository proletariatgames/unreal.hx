package unreal;
import unreal.inputcore.*;
import unreal.slate.*;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputVectorAxisBinding extends FInputBinding {
	/** The axis being bound to. */
	public var AxisKey:FKey;

	/**
	 * The delegate bound to the axis.
	 * It will be called each frame that the input component is in the input stack
	 * regardless of whether the value is non-zero or has changed.
	 */
	public var AxisDelegate:FInputVectorAxisUnifiedDelegate;

	/**
	 * The value of the axis as calculated during the most recent UPlayerInput::ProcessInputStack
	 * if the InputComponent containing the binding was in the stack, otherwise the value will be (0,0,0).
	 */
	public var AxisValue:FVector;

  function new(InAxisKey:FKey);
}