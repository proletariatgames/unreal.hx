package unreal;

extern class UMaterialInstanceDynamic_Extra
{
  public function SetFontParameterValue(ParamaterName:FName, FontValue:UFont, FontPage:Int32) : Void;
  public function ClearParameterValues() : Void;
  public static function Create(ParentMaterial:UMaterialInterface, InOuter:UObject) : UMaterialInstanceDynamic;
}
