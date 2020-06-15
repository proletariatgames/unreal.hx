package unreal.umg;

@:umodule("UMG")
@:glueCppIncludes("UMG.h")
@:uextern extern class UWidget_Extra extends unreal.umg.UVisual {

  @:thisConst
  public function GetCachedWidget() : TSharedPtr<SWidget>;

  @:thisConst
  public function TakeWidget() : TSharedRef<SWidget>;

  public function SynchronizeProperties() : Void;

  public function AddBinding(DelegateProperty:UDelegateProperty, SourceObject:UObject, BindingPath:Const<PRef<FDynamicPropertyPath>>) : Bool;

  @:thisConst
  public function IsDesignTime() : Bool;

	/** Function called after the underlying SWidget is constructed. */
	private function OnWidgetRebuilt() : Void;

  #if proletariat
	public function SetNavigationExplicit(Direction:unreal.slatecore.EUINavigation, InFocusRecipient:PRef<UWidget>) : Void;

  public function SetNavigationCustom(Direction:unreal.slatecore.EUINavigation, Delegate:FWidgetNavigationDelegate) : Void;
  #end

  private var bIsVolatile:Bool;
}
