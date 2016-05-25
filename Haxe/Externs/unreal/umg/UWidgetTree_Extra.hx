package unreal.umg;

extern class UWidgetTree_Extra {
  @:typeName public function FindWidget<T>(name:Const<PRef<FName>>):PPtr<T>;
  @:uname("FindWidget") public function FindWidgetSimple(name:Const<PRef<FName>>):UWidget;
  public function ForEachWidget(predicate:UWidget->Void):Void;
}
