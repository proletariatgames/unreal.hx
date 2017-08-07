/**
   * 
   * WARNING! This file was autogenerated by: 
   *  _   _ _____     ___   _   _ __   __ 
   * | | | |  ___|   /   | | | | |\ \ / / 
   * | | | | |__    / /| | | |_| | \ V /  
   * | | | |  __|  / /_| | |  _  | /   \  
   * | |_| | |___  \___  | | | | |/ /^\ \ 
   *  \___/\____/      |_/ \_| |_/\/   \/ 
   * 
   * This file was autogenerated by UE4HaxeExternGenerator using UHT definitions. It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
   * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.umgeditor;


/**
  Implements the settings for the Widget Blueprint Designer.
**/
@:umodule("UMGEditor")
@:glueCppIncludes("Settings/WidgetDesignerSettings.h")
@:uextern @:uclass extern class UWidgetDesignerSettings extends unreal.UObject {
  @:uproperty public var bShowOutlines : Bool;
  @:uproperty public var bLockToPanelOnDragByDefault : Bool;
  @:uproperty public var GridSnapSize : unreal.Int32;
  
  /**
    If enabled, actor positions will snap to the grid.
  **/
  @:uproperty public var GridSnapEnabled : Bool;
  
}