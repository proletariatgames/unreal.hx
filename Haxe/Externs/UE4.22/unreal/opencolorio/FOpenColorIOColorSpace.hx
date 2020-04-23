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
package unreal.opencolorio;

/**
  Structure to identify a ColorSpace as described in an OCIO configuration file.
  Members are populated by data coming from a config file.
**/
@:umodule("OpenColorIO")
@:glueCppIncludes("Public/OpenColorIOColorSpace.h")
@:uextern @:ustruct extern class FOpenColorIOColorSpace {
  
  /**
    The family of this ColorSpace as specified in the configuration file.
    When you have lots of colorspaces, you can regroup them by family to facilitate browsing them.
  **/
  @:uproperty public var FamilyName : unreal.FString;
  
  /**
    The index of the ColorSpace in the config
  **/
  @:uproperty public var ColorSpaceIndex : unreal.Int32;
  
  /**
    The ColorSpace name.
  **/
  @:uproperty public var ColorSpaceName : unreal.FString;
  
}