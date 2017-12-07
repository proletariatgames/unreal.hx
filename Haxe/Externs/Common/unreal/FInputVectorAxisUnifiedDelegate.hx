package unreal;
import unreal.inputcore.FKey;
import unreal.inputcore.ETouchIndex;

/** Unified delegate specialization for Touch events. */
@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputVectorAxisUnifiedDelegate {

  public function new();

  @:thisConst
  public function Execute(AxisValue:FVector) : Void;

  public function BindDelegate(object:UObject, funcName:FName):Void;

  public function GetDelegateForManualSet():PRef<FInputVectorAxisHandlerSignature>;
}

typedef FInputVectorAxisHandlerSignature = Delegate<FInputVectorAxisHandlerSignature, FVector->Void>;