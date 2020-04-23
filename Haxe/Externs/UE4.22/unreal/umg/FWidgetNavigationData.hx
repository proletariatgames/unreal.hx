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

@:umodule("UMG")
@:glueCppIncludes("UMG.h", "Public/Blueprint/WidgetNavigation.h")
@:uextern @:ustruct extern class FWidgetNavigationData {
  @:uproperty public var CustomDelegate : unreal.umg.FCustomWidgetNavigationDelegate;
  @:uproperty public var Widget : unreal.TWeakObjectPtr<unreal.umg.UWidget>;
  
  /**
    This either the widget to focus, OR the name of the function to call.
  **/
  @:uproperty public var WidgetToFocus : unreal.FName;
  @:uproperty public var Rule : unreal.slatecore.EUINavigationRule;
  
}