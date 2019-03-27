package unreal;
import unreal.inputcore.FKey;
import unreal.inputcore.ETouchIndex;

/** Unified delegate specialization for Touch events. */
@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputAxisUnifiedDelegate {

  public function new();

  @:thisConst
  public function Execute(AxisValue:Float32) : Void;

  public function BindDelegate(object:UObject, funcName:FName):Void;

  public function GetDelegateForManualSet():PRef<FInputAxisHandlerSignature>;

  public function Unbind() : Void;
}

typedef FInputAxisHandlerSignature = Delegate<FInputAxisHandlerSignature, Float32->Void>;