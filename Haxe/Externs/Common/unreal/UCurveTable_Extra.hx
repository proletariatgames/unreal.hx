package unreal;

extern class UCurveTable_Extra {
  #if (UE_VER >= 4.22)
  @:thisConst
  public function FindCurve(RowName:FName, ContextString:PRef<Const<FString>>, bWarnIfNotFound:Bool=true) : PPtr<FRealCurve>;
  @:thisConst
  public function FindRichCurve(RowName:FName, ContextString:PRef<Const<FString>>, bWarnIfNotFound:Bool=true) : PPtr<FRichCurve>;
  #else
  public function FindCurve(RowName:FName, ContextString:Const<PRef<FString>>, bWarnIfNotFound:Bool) : PPtr<FRichCurve>;
  #end
}
