package unreal;

extern class UInputComponent_Extra {

  /**
   * Binds a delegate function to an Action defined in the project settings.
   * Returned reference is only guaranteed to be valid until another action is bound.
   */
  public function BindAction(actionName:Const<FName>, keyEvent:EInputEvent, object:UObject, func:MethodPointer<UObject,Void->Void>) : PRef<FInputActionBinding>;


  /**
   * Binds a delegate function an Axis defined in the project settings.
   * Returned reference is only guaranteed to be valid until another axis is bound.
   */
  public function BindAxis(axisName:Const<FName>, object:UObject, func:MethodPointer<UObject,Float32->Void>) : PRef<FInputAxisBinding>;

  /**
  * Removes all action bindings.
  */
  public function ClearActionBindings() : Void;
}
