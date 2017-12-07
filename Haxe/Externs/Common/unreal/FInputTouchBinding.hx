package unreal;
import unreal.inputcore.*;
import unreal.slate.*;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputTouchBinding extends FInputBinding {
	/** Key event to bind it to (e.g. pressed, released, double click) */
	public var KeyEvent:EInputEvent;

	/** The delegate bound to the touch events */
	public var TouchDelegate:FInputTouchUnifiedDelegate;

  function new(InKeyEvent:EInputEvent);
}