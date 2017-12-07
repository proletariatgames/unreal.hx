package unreal;
import unreal.inputcore.FKey;
import unreal.inputcore.ETouchIndex;

/** Unified delegate specialization for Touch events. */
@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputTouchUnifiedDelegate {

  public function new();

  @:thisConst
  public function Execute(FingerIndex:ETouchIndex, Location:FVector) : Void;

  public function BindDelegate(object:UObject, funcName:FName):Void;

  public function GetDelegateForManualSet():PRef<FInputTouchHandlerSignature>;

  public function Unbind() : Void;
}

typedef FInputTouchHandlerSignature = Delegate<FInputTouchHandlerSignature, ETouchIndex->FVector->Void>;