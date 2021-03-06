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
package unreal.applearkit;

/**
  A light estimate represented as spherical harmonics
**/
@:umodule("AppleARKit")
@:glueCppIncludes("Public/AppleARKitLightEstimate.h")
@:uextern @:ustruct extern class FAppleARKitLightEstimate {
  
  /**
    Color Temperature in Kelvin of light
  **/
  @:uproperty public var AmbientColorTemperatureKelvin : unreal.Float32;
  
  /**
    Ambient intensity of the lighting.
    
    In a well lit environment, this value is close to 1000. It typically ranges from 0
    (very dark) to around 2000 (very bright).
  **/
  @:uproperty public var AmbientIntensity : unreal.Float32;
  
  /**
    True if light estimation was enabled for the session and light estimation was successful
  **/
  @:uproperty public var bIsValid : Bool;
  
}
