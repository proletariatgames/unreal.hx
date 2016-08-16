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

  public function SetRenderTransform(transform:FWidgetTransform) : Void;

  /** The render transform of the widget allows for arbitrary 2D transforms to be applied to the widget. */
  var RenderTransform:FWidgetTransform;

	/**
	 * The render transform pivot controls the location about which transforms are applied.
	 * This value is a normalized coordinate about which things like rotations will occur.
	 */
  var RenderTransformPivot:FVector2D;

}
