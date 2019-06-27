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
package unreal.umgeditor;

/**
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("UMGEditor")
@:glueCppIncludes("K2Node_WidgetAnimationEvent.h")
@:uextern @:uclass extern class UK2Node_WidgetAnimationEvent extends unreal.blueprintgraph.UK2Node_Event {
  @:uproperty public var SourceWidgetBlueprint : unreal.umgeditor.UWidgetBlueprint;
  
  /**
    Binds this to a specific user action.
  **/
  @:uproperty public var UserTag : unreal.FName;
  
  /**
    Name of property in Blueprint class that pointer to component we want to bind to
  **/
  @:uproperty public var AnimationPropertyName : unreal.FName;
  
  /**
    The action to bind to.
  **/
  @:uproperty public var Action : unreal.umg.EWidgetAnimationEvent;
  
}