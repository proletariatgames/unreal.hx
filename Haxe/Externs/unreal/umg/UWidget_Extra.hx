package unreal.umg;

@:umodule("UMG")
@:glueCppIncludes("UMG.h")
@:uextern extern class UWidget_Extra extends unreal.umg.UVisual {

  @:thisConst
  public function GetCachedWidget() : TSharedPtr<SWidget>;

}
