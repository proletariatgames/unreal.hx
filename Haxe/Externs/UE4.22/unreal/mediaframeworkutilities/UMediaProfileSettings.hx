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
  Settings for the media profile.
**/
@:umodule("MediaFrameworkUtilities")
@:glueCppIncludes("Profile/MediaProfileSettings.h")
@:uextern @:uclass extern class UMediaProfileSettings extends unreal.UObject {
  
  /**
    Apply the startup media profile even when we are running a commandlet.
    @note We always try to apply the user media profile before the startup media profile in the editor or standalone.
  **/
  @:uproperty public var bApplyInCommandlet : Bool;
  
}
