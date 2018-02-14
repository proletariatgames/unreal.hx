package unreal;

extern class UDataTable_Extra {
  @:uname("FindRow")
  @:typename public function FindRow_Template<T : FTableRowBase>(RowName:FName, ContextString:Const<PRef<FString>>, bWarnIfRowMissing:Bool) : PPtr<T>;
}
