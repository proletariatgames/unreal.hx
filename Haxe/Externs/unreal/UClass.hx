package unreal;

@:glueCppIncludes("UObject/Class.h")
@:uextern extern class UClass extends UStruct
{
  public static function StaticClass():UClass;
  public function GetSuperClass() : UClass;
  @:global
  public static function FindField<T>(Owner:PExternal<UStruct>, FieldName:PStruct<FName>) : PExternal<T>;
}
