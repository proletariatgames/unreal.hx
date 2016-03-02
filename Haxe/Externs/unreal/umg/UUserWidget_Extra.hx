package unreal.umg;

import unreal.slatecore.*;

extern class UUserWidget_Extra {
  @:global @:typeName
  public static function CreateWidget<T> (OwningPlayer:APlayerController, UserWidgetClass:UClass) : PExternal<T>;
  private function NativeTick(MyGeometry:Const<PRef<FGeometry>>, InDeltaTime:Float32):Void;
  private function NativeConstruct():Void;
}
