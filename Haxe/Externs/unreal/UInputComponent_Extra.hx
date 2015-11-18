package unreal;

extern class UInputComponent_Extra {

  public function BindAction<UserClass>(actionName:Const<PRef<FName>>, keyEvent:EInputEvent, object:UserClass, func:MethodPointer<UserClass,Void->Void>) : PRef<FInputActionBinding>;
}
