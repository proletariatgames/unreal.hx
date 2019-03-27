package unreal;
import unreal.inputcore.FKey;
import unreal.inputcore.ETouchIndex;

/** Unified delegate specialization for Touch events. */
@:glueCppIncludes('Components/InputComponent.h')
@:uextern extern class FInputGestureUnifiedDelegate {

  public function new();

  @:thisConst
  public function Execute(AxisValue:Float32) : Void;

  public function Unbind() : Void;

  public function BindDelegate(object:UObject, funcName:FName):Void;

  public function GetDelegateForManualSet():PRef<FInputGestureHandlerSignature>;
}

typedef FInputGestureHandlerSignature = Delegate<FInputGestureHandlerSignature, Float32->Void>;