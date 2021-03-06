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
  Asset to manage whitelisted OpenColorIO color spaces. This will create required transform objects.
**/
@:umodule("OpenColorIO")
@:glueCppIncludes("OpenColorIOConfiguration.h")
@:uextern @:uclass extern class UOpenColorIOConfiguration extends unreal.UObject {
  @:uproperty public var DesiredColorSpaces : unreal.TArray<unreal.opencolorio.FOpenColorIOColorSpace>;
  @:uproperty public var ConfigurationFile : unreal.FFilePath;
  
}
