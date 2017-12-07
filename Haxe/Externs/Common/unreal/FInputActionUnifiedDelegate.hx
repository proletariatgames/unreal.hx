package unreal;

import unreal.inputcore.FKey;

@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputActionUnifiedDelegate {

  public function new();

  @:thisConst
  public function Execute(Key:Const<FKey>) : Void;

  public function Unbind() : Void;

  @:uname('.ctor') static function createWithDelegate(d:Const<PRef<FInputActionUnifiedDelegate>>):FInputActionUnifiedDelegate;
  @:uname('.ctor') static function createWithDelegateWithKey(d:Const<PRef<FInputActionHandlerWithKeySignature>>):FInputActionUnifiedDelegate;
  @:uname('.ctor') static function createWithDynamicDelegate(d:Const<PRef<FInputActionHandlerDynamicSignature>>):FInputActionUnifiedDelegate;
}

typedef FInputActionHandlerSignature = Delegate<FInputActionHandlerSignature, Void->Void>;

typedef FInputActionHandlerWithKeySignature = Delegate<FInputActionHandlerWithKeySignature, FKey->Void>;