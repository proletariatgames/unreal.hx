package unreal;

extern class UMaterialInstanceDynamic_Extra
{
  public function SetScalarParameterValue(ParameterName:FName, Value:Float32) : Void;
  public function SetTextureParameterValue(ParameterName:FName, Value:UTexture) : Void;
  public function SetVectorParameterValue(ParameterName:FName, Value:FLinearColor) : Void;
  public function SetFontParameterValue(ParamaterName:FName, FontValue:UFont, FontPage:Int32) : Void;
  public function ClearParameterValues() : Void;
  public function CopyParameterOverrides(MaterialInstance:UMaterialInstance) : Void;
  public static function Create(ParentMaterial:UMaterialInterface, InOuter:UObject) : UMaterialInstanceDynamic;
}
