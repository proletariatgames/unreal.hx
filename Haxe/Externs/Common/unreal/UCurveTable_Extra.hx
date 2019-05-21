package unreal;

extern class UCurveTable_Extra {
  @:thisConst
  public function FindCurve(RowName:FName, ContextString:PRef<Const<FString>>, bWarnIfNotFound:Bool=true) : PPtr<FRealCurve>;
  @:thisConst
  public function FindRichCurve(RowName:FName, ContextString:PRef<Const<FString>>, bWarnIfNotFound:Bool=true) : PPtr<FRichCurve>;
}
