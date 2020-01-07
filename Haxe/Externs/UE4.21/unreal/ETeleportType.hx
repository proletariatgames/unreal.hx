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
  Whether to teleport physics body or not
**/
@:glueCppIncludes("Classes/Engine/EngineTypes.h")
@:uname("ETeleportType")
@:class @:uextern @:uenum extern enum ETeleportType {
  
  /**
    Do not teleport physics body. This means velocity will reflect the movement between initial and final position, and collisions along the way will occur
  **/
  None;
  
  /**
    Teleport physics body so that velocity remains the same and no collision occurs
  **/
  TeleportPhysics;
  
  /**
    Teleport physics body and reset physics state completely
  **/
  ResetPhysics;
  
}