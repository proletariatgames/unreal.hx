package unreal;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputActionBinding extends FInputBinding {

  function new(ActionName:FName, Event:EInputEvent);

#if (UE_VER <= 4.19)
  /** Friendly name of action, e.g "jump" */
  public var ActionName : FName;
#end

  /** Key event to bind it to, e.g. pressed, released, double click */
  public var KeyEvent : EInputEvent;

#if (UE_VER <= 4.19)
  /** Whether the binding is part of a paired (both pressed and released events bound) action */
  public var bPaired : Bool;
#end

  /** The delegate bound to the action */
  public var ActionDelegate : FInputActionUnifiedDelegate;

#if (UE_VER > 4.19)
  @:thisConst
  public function GetActionName():FName;
  @:thisConst
  public function IsPaired():Bool;
#end

}