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
  The update method for the offset
**/
@:glueCppIncludes("Classes/Particles/Camera/ParticleModuleCameraOffset.h")
@:uname("EParticleCameraOffsetUpdateMethod")
@:uextern @:uenum extern enum EParticleCameraOffsetUpdateMethod {
  
  /**
    Direct Set
  **/
  @DisplayName("Direct Set")
  EPCOUM_DirectSet;
  
  /**
    Additive
  **/
  @DisplayName("Additive")
  EPCOUM_Additive;
  
  /**
    Scalar
  **/
  @DisplayName("Scalar")
  EPCOUM_Scalar;
  EPCOUM_MAX;
  
}
