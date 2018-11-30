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
package unreal.statsviewer;

/**
  Enum defining the object sets for this stats object
**/
@:umodule("StatsViewer")
@:glueCppIncludes("Classes/TextureStats.h")
@:uname("ETextureObjectSets")
@:uextern @:uenum extern enum ETextureObjectSets {
  
  /**
    Display texture statistics for the current streaming level
    @DisplayName Current Streaming Level
  **/
  @DisplayName("Current Streaming Level")
  TextureObjectSet_CurrentStreamingLevel;
  
  /**
    Display texture statistics for all streaming levels
    @DisplayName All Streaming Levels
  **/
  @DisplayName("All Streaming Levels")
  TextureObjectSet_AllStreamingLevels;
  
  /**
    Display texture statistics of selected Actors
    @DisplayName Selected Actor(s)
  **/
  @DisplayName("Selected Actor(s)")
  TextureObjectSet_SelectedActors;
  
  /**
    Display texture statistics of selected Materials
    @DisplayName Selected Materials(s)
  **/
  @DisplayName("Selected Materials(s)")
  TextureObjectSet_SelectedMaterials;
  
}