package unreal;

extern class UClass_Extra {
  public function GetSuperClass() : UClass;
  @:global @:typeName
  public static function FindField<T>(Owner:PExternal<UStruct>, FieldName:PStruct<FName>) : PExternal<T>;

  @:typeName public function GetDefaultObject<T:UObject>() : PExternal<T>;

  public function HasAllClassFlags(flags:Int32):Bool;
}
