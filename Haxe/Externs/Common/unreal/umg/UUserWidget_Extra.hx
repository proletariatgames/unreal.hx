package unreal.umg;

import unreal.slatecore.*;

extern class UUserWidget_Extra {
  @:global @:typeName
  public static function CreateWidget<T> (OwningPlayer:APlayerController, UserWidgetClass:UClass) : PPtr<T>;
  private function NativeTick(MyGeometry:Const<PRef<FGeometry>>, InDeltaTime:Float32):Void;
  private function NativeConstruct():Void;
  private function NativeOnMouseButtonDown(MyGeometry : Const<PRef<FGeometry>>, InMouseEvent : Const<PRef<FPointerEvent>>) : FReply;
  private function NativeOnMouseEnter(MyGeometry : Const<PRef<FGeometry>>, MouseEvent : Const<PRef<FPointerEvent>>) : Void;
  private function NativeOnMouseLeave(InMouseEvent : Const<PRef<FPointerEvent>>) : Void;
  private function NativeOnKeyDown (InGeometry : Const<PRef<FGeometry>>, InKeyEvent : Const<PRef<FKeyEvent>>) : FReply;
  private function NativeOnDragCancelled(InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Void;
  private function NativeOnDragEnter(InGeometry : Const<PRef<FGeometry>>, InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Void;
  private function NativeOnDragLeave(InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Void;
  private function NativeOnDragOver(InGeometry : Const<PRef<FGeometry>>, InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Bool;
  private function NativeOnDrop(InGeometry : Const<PRef<FGeometry>>, InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Bool;
  private function NativeOnFocusReceived (InGeometry : Const<PRef<FGeometry>>, InFocusEvent : Const<PRef<FFocusEvent>>) : FReply;
  public function OnAnimationFinished_Implementation (Animation:Const<UWidgetAnimation>):Void;
  public function OnAnimationStarted_Implementation (Animation:Const<UWidgetAnimation>):Void;

  private function OnLevelRemovedFromWorld(InLevel:ULevel, InWorld:UWorld) : Void;
}
