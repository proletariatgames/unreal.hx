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
  How particles respond to collision events.
**/
@:glueCppIncludes("Classes/Particles/Collision/ParticleModuleCollisionGPU.h")
@:uname("EParticleCollisionResponse.Type")
@:uextern @:uenum extern enum EParticleCollisionResponse {
  
  /**
    The particle will bounce off of the surface.
  **/
  Bounce;
  
  /**
    The particle will stop on the surface.
  **/
  Stop;
  
  /**
    The particle will be killed.
  **/
  Kill;
  
}
