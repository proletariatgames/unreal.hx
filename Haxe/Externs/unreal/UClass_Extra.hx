package unreal;

extern class UClass_Extra {
  public function GetSuperClass() : UClass;
  @:global @:typeName
  public static function FindField<T>(Owner:PExternal<UStruct>, FieldName:PStruct<FName>) : PExternal<T>;

  public function IsChildOf(SomeBase:Const<UStruct>) : Bool ;

  @:typeName public function GetDefaultObject<T:UObject>() : PExternal<T>;
}
