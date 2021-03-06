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
package unreal.qos;

/**
  Individual ping server details
**/
@:umodule("Qos")
@:glueCppIncludes("Public/QosRegionManager.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FQosPingServerInfo {
  
  /**
    Port of server
  **/
  @:uproperty public var Port : unreal.Int32;
  
  /**
    Address of server
  **/
  @:uproperty public var Address : unreal.FString;
  
}
