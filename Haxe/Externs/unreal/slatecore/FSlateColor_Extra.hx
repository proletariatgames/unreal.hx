package unreal.slatecore;

extern class FSlateColor_Extra {
  @:uname("new") static function create(color:Const<PRef<FLinearColor>>):POwnedPtr<FSlateColor>;
}