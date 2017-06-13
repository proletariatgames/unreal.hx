package unreal.slatecore;

import unreal.inputcore.*;

extern class FPointerEvent_Extra {
  public function GetScreenSpacePosition() : Const<PRef<FVector2D>>;
  public function GetLastScreenSpacePosition() : Const<PRef<FVector2D>>;
  public function GetEffectingButton() : FKey;
}
