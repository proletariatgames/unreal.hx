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
package unreal.mediaframeworkutilities;

/**
  Settings for the media profile in the editor or standalone.
  @note For cook games always use the startup media profile
**/
@:umodule("MediaFrameworkUtilities")
@:glueCppIncludes("Profile/MediaProfileSettings.h")
@:uextern @:uclass extern class UMediaProfileEditorSettings extends unreal.UObject {
  
  /**
    Display the media profile icon in the editor toolbar.
  **/
  @:uproperty public var bDisplayInToolbar : Bool;
  
}