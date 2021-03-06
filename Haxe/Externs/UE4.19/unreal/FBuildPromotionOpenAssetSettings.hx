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
package unreal;

/**
  Holds settings for the open assets stage of the build promotion test
**/
@:glueCppIncludes("Classes/Tests/AutomationTestSettings.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FBuildPromotionOpenAssetSettings {
  
  /**
    The texture asset to open
  **/
  @:uproperty public var TextureAsset : unreal.FFilePath;
  
  /**
    The static mesh asset to open
  **/
  @:uproperty public var StaticMeshAsset : unreal.FFilePath;
  
  /**
    The skeletal mesh asset to open
  **/
  @:uproperty public var SkeletalMeshAsset : unreal.FFilePath;
  
  /**
    The particle system asset to open
  **/
  @:uproperty public var ParticleSystemAsset : unreal.FFilePath;
  
  /**
    The material asset to open
  **/
  @:uproperty public var MaterialAsset : unreal.FFilePath;
  
  /**
    The blueprint asset to open
  **/
  @:uproperty public var BlueprintAsset : unreal.FFilePath;
  
}
