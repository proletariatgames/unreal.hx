package unreal;

extern class UObject
{
  public function IsAsset():Bool;
  public function GetClass():UClass;
  public function GetDesc():FString;
  public function GetDefaultConfigFilename():FString;
  public function IsPostLoadThreadSafe():Bool;
  public function PostLoad():Void;
}
