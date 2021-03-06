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
package unreal.gameplayabilities;

/**
  How the ability is instanced when executed. This limits what an ability can do in its implementation. For example, a NonInstanced
  Ability cannot have state. It is probably unsafe for an InstancedPerActor ability to have latent actions, etc.
**/
@:umodule("GameplayAbilities")
@:glueCppIncludes("Public/Abilities/GameplayAbilityTypes.h")
@:uname("EGameplayAbilityInstancingPolicy.Type")
@:uextern @:uenum extern enum EGameplayAbilityInstancingPolicy {
  
  /**
    This ability is never instanced. Anything that executes the ability is operating on the CDO.
  **/
  NonInstanced;
  
  /**
    Each actor gets their own instance of this ability. State can be saved, replication is possible.
  **/
  InstancedPerActor;
  
  /**
    We instance this ability each time it is executed. Replication possible but not recommended.
  **/
  InstancedPerExecution;
  
}
