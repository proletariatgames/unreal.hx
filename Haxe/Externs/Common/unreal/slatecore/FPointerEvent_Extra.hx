package unreal.slatecore;

import unreal.inputcore.*;

extern class FPointerEvent_Extra {
  @:uname('.ctor') public static function createWithValues(InPointerIndex:Int32, InScreenSpacePosition:Const<PRef<FVector2D>>, InLastScreenSpacePosition:Const<PRef<FVector2D>>, InPressedButtons:Const<PRef<TSet<FKey>>>, InEffectingButton:FKey, InWheelDelta:Float32, InModifierKeysState:Const<PRef<FModifierKeysState>>) : FPointerEvent;

  public function GetScreenSpacePosition() : Const<PRef<FVector2D>>;
  public function GetLastScreenSpacePosition() : Const<PRef<FVector2D>>;
  public function GetEffectingButton() : FKey;
}
