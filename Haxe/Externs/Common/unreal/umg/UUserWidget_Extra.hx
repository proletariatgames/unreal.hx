package unreal.umg;

import unreal.slatecore.*;

extern class UUserWidget_Extra {
	@:global @:noTemplate
	@:uname("CreateWidget<UUserWidget>") public static function CreateWidget<T : UUserWidget> (OwningPlayer:APlayerController, UserWidgetClass:UClass) : T;
	@:global @:typeName
	@:uname("CreateWidget") public static function CreateWidget_Template<T> (OwningPlayer:APlayerController, UserWidgetClass:UClass) : PPtr<T>;

	@:global @:noTemplate
	@:uname("CreateWidget<UUserWidget>") public static function CreateWidgetWithGameInstance<T : UUserWidget>(InGameInstance:UGameInstance, UserWidgetClass:UClass) : T;

	@:global @:noTemplate
	@:uname("CreateWidget<UUserWidget>") public static function CreateWidgetWithWorld<T : UUserWidget>(InWorld:UWorld, UserWidgetClass:UClass) : T;

#if (UE_VER <= 4.19)
	public static function CreateWidgetOfClass(UserWidgetClass:UClass, InGameInstance:UGameInstance, InWorld:UWorld, InOwningPlayer:APlayerController):UUserWidget;
#else
	public static function CreateWidgetInstance(OwnerPC:PRef<APlayerController>, UserWidgetClass:TSubclassOf<UUserWidget>, WidgetName:FName):UUserWidget;
#end

	private function NativeTick(MyGeometry:Const<PRef<FGeometry>>, InDeltaTime:Float32):Void;
	private function NativePreConstruct():Void;
	private function NativeConstruct():Void;
	private function NativeOnMouseButtonDown(MyGeometry : Const<PRef<FGeometry>>, InMouseEvent : Const<PRef<FPointerEvent>>) : FReply;
	private function NativeOnMouseEnter(MyGeometry : Const<PRef<FGeometry>>, MouseEvent : Const<PRef<FPointerEvent>>) : Void;
	private function NativeOnMouseLeave(InMouseEvent : Const<PRef<FPointerEvent>>) : Void;
	private function NativeOnKeyDown (InGeometry : Const<PRef<FGeometry>>, InKeyEvent : Const<PRef<FKeyEvent>>) : FReply;
	private function NativeOnKeyUp (InGeometry : Const<PRef<FGeometry>>, InKeyEvent : Const<PRef<FKeyEvent>>) : FReply;
	private function NativeOnDragDetected(MyGeometry : Const<PRef<FGeometry>>, MouseEvent : Const<PRef<FPointerEvent>>, Operation : Ref<unreal.umg.UDragDropOperation>) : Void;
	private function NativeOnDragCancelled(InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Void;
	private function NativeOnDragEnter(InGeometry : Const<PRef<FGeometry>>, InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Void;
	private function NativeOnDragLeave(InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Void;
	private function NativeOnDragOver(InGeometry : Const<PRef<FGeometry>>, InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Bool;
	private function NativeOnDrop(InGeometry : Const<PRef<FGeometry>>, InDragDropEvent : Const<PRef<FDragDropEvent>>, InOperation : UDragDropOperation) : Bool;
	private function NativeOnFocusReceived (InGeometry : Const<PRef<FGeometry>>, InFocusEvent : Const<PRef<FFocusEvent>>) : FReply;
 	private function NativeOnFocusLost(InFocusEvent : Const<PRef<FFocusEvent>>) : Void;
	@:thisConst
	private function NativeSupportsKeyboardFocus() : Bool;

	private function OnAnimationFinished_Implementation (Animation:Const<UWidgetAnimation>):Void;
	private function OnAnimationStarted_Implementation (Animation:Const<UWidgetAnimation>):Void;

	private function OnLevelRemovedFromWorld(InLevel:ULevel, InWorld:UWorld) : Void;

	@:ufunction(BlueprintImplementableEvent) public function OnDragDetected(MyGeometry : FGeometry, MouseEvent : Const<PRef<FPointerEvent>>, Operation : Ref<unreal.umg.UDragDropOperation>) : Void;

	@:ureplace @:ufunction(BlueprintCallable) @:final private function ListenForInputAction(ActionName : unreal.FName, EventType : unreal.TEnumAsByte<unreal.EInputEvent>, bConsume : Bool, Callback : unreal.umg.FOnInputAction) : Void;
	#if proletariat
		@:final private function ListenForInputAxis(AxisName : unreal.FName, EventType : unreal.TEnumAsByte<unreal.EInputEvent>, bConsume : Bool, Callback : unreal.umg.FOnInputAxis) : Void;
		@:final private function StopListeningForInputAxis(AxisName : unreal.FName) : Void;
	#end
	@:ureplace @:ufunction(BlueprintCallable) @:final private function StopListeningForInputAction(ActionName : unreal.FName, EventType : unreal.TEnumAsByte<unreal.EInputEvent>) : Void;
}
