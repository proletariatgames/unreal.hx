package unreal;

extern class FDataTableRowHandle_Extra
{
  @:thisConst
  public function GetRow<T>(ContextString : Const<PRef<FString>>) : PPtr<T>;

  @:thisConst
  public function IsNull() : Bool;
}
