package unreal;
import unreal.slate.*;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputKeyBinding extends FInputBinding {
	/** Input Chord to bind to */
	public var Chord:FInputChord;

	/** Key event to bind it to (e.g. pressed, released, double click) */
	public var KeyEvent:EInputEvent;

	/** The delegate bound to the key chord */
	public var  KeyDelegate:FInputActionUnifiedDelegate;

  function new(InCHord:FInputChord, InKeyEvent:EInputEvent);
}