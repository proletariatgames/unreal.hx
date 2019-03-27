package unreal.slatecore;

extern class FSlateColor_Extra {
  @:uname(".ctor") static function create(color:Const<PRef<FLinearColor>>):FSlateColor;
  @:uname("new") static function createNew(color:Const<PRef<FLinearColor>>):POwnedPtr<FSlateColor>;

  public function GetSpecifiedColor() : Const<FLinearColor>;
}
