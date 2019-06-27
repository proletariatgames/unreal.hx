/**
 * 
 * WARNING! This file was autogenerated by: 
 *  _   _ _   _ __   __ 
 * | | | | | | |\ \ / / 
 * | | | | |_| | \ V /  
 * | | | |  _  | /   \  
 * | |_| | | | |/ /^\ \ 
 *  \___/\_| |_/\/   \/ 
 * 
 * This file was autogenerated by UnrealHxGenerator using UHT definitions.
 * It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
 * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.umg;

/**
  A border is a container widget that can contain one child widget, providing an opportunity
  to surround it with a background image and adjustable padding.
  
  * Single Child
  * Image
**/
@:umodule("UMG")
@:glueCppIncludes("UMG.h")
@:uextern @:uclass extern class UBorder extends unreal.umg.UContentWidget {
  #if WITH_EDITORONLY_DATA
  
  /**
    Image to use for the border
  **/
  @:deprecated @:uproperty private var Brush_DEPRECATED : unreal.USlateBrushAsset;
  #end // WITH_EDITORONLY_DATA
  @:uproperty public var OnMouseDoubleClickEvent : unreal.umg.FOnPointerEvent;
  @:uproperty public var OnMouseMoveEvent : unreal.umg.FOnPointerEvent;
  @:uproperty public var OnMouseButtonUpEvent : unreal.umg.FOnPointerEvent;
  @:uproperty public var OnMouseButtonDownEvent : unreal.umg.FOnPointerEvent;
  
  /**
    Scales the computed desired size of this border and its contents. Useful
    for making things that slide open without having to hard-code their size.
    Note: if the parent widget is set up to ignore this widget's desired size,
    then changing this value will have no effect.
  **/
  @:uproperty public var DesiredSizeScale : unreal.FVector2D;
  
  /**
    A bindable delegate for the BrushColor.
  **/
  @:uproperty public var BrushColorDelegate : unreal.umg.FGetLinearColor;
  
  /**
    Color and opacity of the actual border image
  **/
  @:uproperty public var BrushColor : unreal.FLinearColor;
  
  /**
    A bindable delegate for the Brush.
  **/
  @:uproperty public var BackgroundDelegate : unreal.umg.FGetSlateBrush;
  
  /**
    Brush to drag as the background
  **/
  @:uproperty public var Background : unreal.slatecore.FSlateBrush;
  
  /**
    The padding area between the slot and the content it contains.
  **/
  @:uproperty public var Padding : unreal.slatecore.FMargin;
  
  /**
    A bindable delegate for the ContentColorAndOpacity.
  **/
  @:uproperty public var ContentColorAndOpacityDelegate : unreal.umg.FGetLinearColor;
  
  /**
    Color and opacity multiplier of content in the border
  **/
  @:uproperty public var ContentColorAndOpacity : unreal.FLinearColor;
  
  /**
    Whether or not to show the disabled effect when this border is disabled
  **/
  @:uproperty public var bShowEffectWhenDisabled : Bool;
  
  /**
    The alignment of the content vertically.
  **/
  @:uproperty public var VerticalAlignment : unreal.slatecore.EVerticalAlignment;
  
  /**
    The alignment of the content horizontally.
  **/
  @:uproperty public var HorizontalAlignment : unreal.slatecore.EHorizontalAlignment;
  @:ufunction(BlueprintCallable) @:final public function SetContentColorAndOpacity(InContentColorAndOpacity : unreal.FLinearColor) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetPadding(InPadding : unreal.slatecore.FMargin) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetHorizontalAlignment(InHorizontalAlignment : unreal.slatecore.EHorizontalAlignment) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetVerticalAlignment(InVerticalAlignment : unreal.slatecore.EVerticalAlignment) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetBrushColor(InBrushColor : unreal.FLinearColor) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetBrush(InBrush : unreal.Const<unreal.PRef<unreal.slatecore.FSlateBrush>>) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetBrushFromAsset(Asset : unreal.USlateBrushAsset) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetBrushFromTexture(Texture : unreal.UTexture2D) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetBrushFromMaterial(Material : unreal.UMaterialInterface) : Void;
  @:ufunction(BlueprintCallable) @:final public function GetDynamicMaterial() : unreal.UMaterialInstanceDynamic;
  
  /**
    Sets the DesireSizeScale of this border.
    
    @param InScale    The X and Y multipliers for the desired size
  **/
  @:ufunction(BlueprintCallable) @:final public function SetDesiredSizeScale(InScale : unreal.FVector2D) : Void;
  
}