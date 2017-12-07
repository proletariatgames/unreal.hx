package unreal;
import unreal.inputcore.*;
import unreal.slate.*;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputGestureBinding extends FInputBinding {
	/** The gesture being bound to. */
	public var GestureKey:FKey;

	/** The delegate bound to the gesture events */
	public var GestureDelegate:FInputGestureUnifiedDelegate;

	/** Value parameter, meaning is dependent on the gesture. */
	public var GestureValue:Float32;

  public function new(InGestureKey:FKey);
}