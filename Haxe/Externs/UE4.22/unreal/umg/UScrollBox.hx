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
  An arbitrary scrollable collection of widgets.  Great for presenting 10-100 widgets in a list.  Doesn't support virtualization.
**/
@:umodule("UMG")
@:glueCppIncludes("UMG.h")
@:uextern @:uclass extern class UScrollBox extends unreal.umg.UPanelWidget {
  
  /**
    Called when the scroll has changed
  **/
  @:uproperty public var OnUserScrolled : unreal.umg.FOnUserScrolledEvent;
  
  /**
    Option to disable right-click-drag scrolling
  **/
  @:uproperty public var bAllowRightClickDragScrolling : Bool;
  
  /**
    The amount of padding to ensure exists between the item being navigated to, at the edge of the
    scrollbox.  Use this if you want to ensure there's a preview of the next item the user could scroll to.
  **/
  @:uproperty public var NavigationScrollPadding : unreal.Float32;
  @:uproperty public var NavigationDestination : unreal.slate.EDescendantScrollDestination;
  
  /**
    Disable to stop scrollbars from activating inertial overscrolling
  **/
  @:uproperty public var AllowOverscroll : Bool;
  @:uproperty public var AlwaysShowScrollbarTrack : Bool;
  @:uproperty public var AlwaysShowScrollbar : Bool;
  @:uproperty public var ScrollbarThickness : unreal.FVector2D;
  
  /**
    When mouse wheel events should be consumed.
  **/
  @:uproperty public var ConsumeMouseWheel : unreal.slatecore.EConsumeMouseWheel;
  
  /**
    Visibility
  **/
  @:uproperty public var ScrollBarVisibility : unreal.umg.ESlateVisibility;
  
  /**
    The orientation of the scrolling and stacking in the box.
  **/
  @:uproperty public var Orientation : unreal.slatecore.EOrientation;
  @:deprecated @:uproperty public var BarStyle_DEPRECATED : unreal.slatecore.USlateWidgetStyleAsset;
  @:deprecated @:uproperty public var Style_DEPRECATED : unreal.slatecore.USlateWidgetStyleAsset;
  
  /**
    The bar style
  **/
  @:uproperty public var WidgetBarStyle : unreal.slatecore.FScrollBarStyle;
  
  /**
    The style
  **/
  @:uproperty public var WidgetStyle : unreal.slatecore.FScrollBoxStyle;
  @:ufunction(BlueprintCallable) @:final public function SetConsumeMouseWheel(NewConsumeMouseWheel : unreal.slatecore.EConsumeMouseWheel) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetOrientation(NewOrientation : unreal.slatecore.EOrientation) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetScrollBarVisibility(NewScrollBarVisibility : unreal.umg.ESlateVisibility) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetScrollbarThickness(NewScrollbarThickness : unreal.Const<unreal.PRef<unreal.FVector2D>>) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetAlwaysShowScrollbar(NewAlwaysShowScrollbar : Bool) : Void;
  @:ufunction(BlueprintCallable) @:final public function SetAllowOverscroll(NewAllowOverscroll : Bool) : Void;
  
  /**
    Updates the scroll offset of the scrollbox.
    @param NewScrollOffset is in Slate Units.
  **/
  @:ufunction(BlueprintCallable) @:final public function SetScrollOffset(NewScrollOffset : unreal.Float32) : Void;
  
  /**
    Gets the scroll offset of the scrollbox in Slate Units.
  **/
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetScrollOffset() : unreal.Float32;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetViewOffsetFraction() : unreal.Float32;
  
  /**
    Scrolls the ScrollBox to the top instantly
  **/
  @:ufunction(BlueprintCallable) @:final public function ScrollToStart() : Void;
  
  /**
    Scrolls the ScrollBox to the bottom instantly during the next layout pass.
  **/
  @:ufunction(BlueprintCallable) @:final public function ScrollToEnd() : Void;
  
  /**
    Scrolls the ScrollBox to the widget during the next layout pass.
  **/
  @:ufunction(BlueprintCallable) @:final public function ScrollWidgetIntoView(WidgetToFind : unreal.umg.UWidget, AnimateScroll : Bool = true, @:opt("IntoView") ScrollDestination : unreal.slate.EDescendantScrollDestination) : Void;
  
}