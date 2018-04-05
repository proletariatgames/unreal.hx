package unreal;

extern class FDataTableRowHandle_Extra
{
  @:thisConst
  public function GetRow<T>(ContextString : Const<PRef<FString>>) : PPtr<T>;
}
