package unreal;

import unreal.inputcore.*;

extern class FInputKeyEventArgs_Extra {
  @:uname('.ctor') public static function createWithValues(InViewport:PPtr<FViewport>, InControllerId:Int32, InKey:FKey, InEvent:EInputEvent) : FInputKeyEventArgs;
}
