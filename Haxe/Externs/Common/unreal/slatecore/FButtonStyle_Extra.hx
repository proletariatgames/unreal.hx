package unreal.slatecore;

extern class FButtonStyle_Extra {
  public function SetNormal(InNormal:Const<PRef<FSlateBrush>>) : PRef<FButtonStyle>;
  public function SetHovered(InHovered:Const<PRef<FSlateBrush>>) : PRef<FButtonStyle>;
  public function SetPressed(InPressed:Const<PRef<FSlateBrush>>) : PRef<FButtonStyle>;
  public function SetDisabled(InDisabled:Const<PRef<FSlateBrush>>) : PRef<FButtonStyle>;
}
