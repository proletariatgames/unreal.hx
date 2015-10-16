package unreal;

@:glueCppIncludes("UObject/Class.h")
@:uextern extern class UClass extends UObject
{
  public static function StaticClass():UClass;
  public function GetSuperClass() : UClass;
}
