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
package unreal.editor;

/**
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("UnrealEd")
@:glueCppIncludes("ThumbnailRendering/SceneThumbnailInfo.h")
@:uextern @:uclass extern class USceneThumbnailInfo extends unreal.UThumbnailInfo {
  
  /**
    The offset from the bounds sphere distance from the asset
  **/
  @:uproperty public var OrbitZoom : unreal.Float32;
  
  /**
    The yaw of the orbit camera around the asset
  **/
  @:uproperty public var OrbitYaw : unreal.Float32;
  
  /**
    The pitch of the orbit camera around the asset
  **/
  @:uproperty public var OrbitPitch : unreal.Float32;
  
}
