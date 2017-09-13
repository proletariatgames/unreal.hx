/**
   * 
   * WARNING! This file was autogenerated by: 
   *  _   _ _____     ___   _   _ __   __ 
   * | | | |  ___|   /   | | | | |\ \ / / 
   * | | | | |__    / /| | | |_| | \ V /  
   * | | | |  __|  / /_| | |  _  | /   \  
   * | |_| | |___  \___  | | | | |/ /^\ \ 
   *  \___/\____/      |_/ \_| |_/\/   \/ 
   * 
   * This file was autogenerated by UE4HaxeExternGenerator using UHT definitions. It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
   * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.gameplayabilities;


/**
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  Applies force to character's movement
**/
@:umodule("GameplayAbilities")
@:glueCppIncludes("Abilities/Tasks/AbilityTask_ApplyRootMotionConstantForce.h")
@:uextern @:uclass extern class UAbilityTask_ApplyRootMotionConstantForce extends unreal.gameplayabilities.UAbilityTask {
  @:uproperty private var MovementComponent : unreal.UCharacterMovementComponent;
  
  /**
    Strength of the force over time
    Curve Y is 0 to 1 which is percent of full Strength parameter to apply
    Curve X is 0 to 1 normalized time if this force has a limited duration (Duration > 0), or
            is in units of seconds if this force has unlimited duration (Duration < 0)
  **/
  @:uproperty private var StrengthOverTime : unreal.UCurveFloat;
  @:uproperty private var Duration : unreal.Float32;
  @:uproperty private var Strength : unreal.Float32;
  @:uproperty private var WorldDirection : unreal.FVector;
  @:uproperty private var ForceName : unreal.FName;
  
}