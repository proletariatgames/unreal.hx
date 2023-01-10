package unreal;

extern class UDataTable_Extra {
  @:uname("FindRow")
  @:typename public function FindRow_Template<T : FTableRowBase>(RowName:FName, ContextString:Const<PRef<FString>>, bWarnIfRowMissing:Bool) : PPtr<T>;

	@:thisConst public function GetAllRows<T : FTableRowBase>(ContextString:Const<PRef<FString>>, OutRowArray:PRef<TArray<PPtr<T>>>) : Void;

	@:thisConst public function GetRowNames() : TArray<FName>;
}
