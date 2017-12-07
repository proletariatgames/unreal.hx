package unreal;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputActionBinding extends FInputBinding {

  function new(ActionName:FName, Event:EInputEvent);

  /** Friendly name of action, e.g "jump" */
  public var ActionName : FName;

  /** Key event to bind it to, e.g. pressed, released, double click */
  public var KeyEvent : EInputEvent;

  /** Whether the binding is part of a paired (both pressed and released events bound) action */
  public var bPaired : Bool;

  /** The delegate bound to the action */
  public var ActionDelegate : FInputActionUnifiedDelegate;

}