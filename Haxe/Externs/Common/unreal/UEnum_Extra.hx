package unreal;

extern class UEnum_Extra {
  public var CppType:FString;

  @:thisConst public function GetValueByName(InName:FName, Flags:EGetByNameFlags):Int64;
}
