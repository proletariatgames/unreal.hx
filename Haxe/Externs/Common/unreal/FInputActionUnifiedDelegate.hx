package unreal;

import unreal.inputcore.FKey;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputActionUnifiedDelegate {

  @:thisConst
  public function Execute(Key:Const<FKey>) : Void;

}