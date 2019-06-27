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
  Whether to override the sync/async scene used by a dynamic actor
**/
@:glueCppIncludes("Classes/PhysicsEngine/BodyInstance.h")
@:uname("EDynamicActorScene")
@:class @:uextern @:uenum extern enum EDynamicActorScene {
  
  /**
    Use whatever the body instance wants
  **/
  Default;
  
  /**
    use sync scene
  **/
  UseSyncScene;
  
  /**
    use async scene
  **/
  UseAsyncScene;
  
}