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
package unreal.virtualcamera;

/**
  Keeps track of all data associated with settings presets.
**/
@:umodule("VirtualCamera")
@:glueCppIncludes("Public/VirtualCameraSaveGame.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FVirtualCameraSettingsPreset {
  @:uproperty public var DateCreated : unreal.FDateTime;
  @:uproperty public var CameraSettings : unreal.virtualcamera.FVirtualCameraSettings;
  
  /**
    Checks if saettings is set as favorite
  **/
  @:uproperty public var bIsFavorited : Bool;
  @:uproperty public var bIsMotionScaleSettingsSaved : Bool;
  @:uproperty public var bIsAxisLockingSettingsSaved : Bool;
  @:uproperty public var bIsStabilizationSettingsSaved : Bool;
  
  /**
    Checks which settings are saved for the preset
  **/
  @:uproperty public var bIsCameraSettingsSaved : Bool;
  
}
