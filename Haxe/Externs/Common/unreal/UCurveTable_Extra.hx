package unreal;

extern class UCurveTable_Extra {
  public function FindCurve(RowName:FName, ContextString:Const<PRef<FString>>, bWarnIfNotFound:Bool) : PPtr<FRichCurve>;
}
