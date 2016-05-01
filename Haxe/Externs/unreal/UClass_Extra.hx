package unreal;

extern class UClass_Extra {
  public function GetSuperClass() : UClass;
  @:global @:typeName
  public static function FindField<T>(Owner:PPtr<UStruct>, FieldName:FName) : PPtr<T>;

  @:typeName public function GetDefaultObject<T:UObject>() : PPtr<T>;

  public function HasAllClassFlags(flags:Int32):Bool;
}
