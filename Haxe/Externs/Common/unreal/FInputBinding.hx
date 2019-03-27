package unreal;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputBinding {
  function new();

  /** Whether the binding should consume the input or allow it to pass to another component */
	public var bConsumeInput:Bool;

	/** Whether the binding should execute while paused */
	public var bExecuteWhenPaused:Bool;
}