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
  Waits for the actor to activate another ability
**/
@:umodule("GameplayAbilities")
@:glueCppIncludes("Abilities/Tasks/AbilityTask_WaitAbilityActivate.h")
@:uextern @:uclass extern class UAbilityTask_WaitAbilityActivate extends unreal.gameplayabilities.UAbilityTask {
  @:uproperty public var OnActivate : unreal.gameplayabilities.FWaitAbilityActivateDelegate;
  @:ufunction @:final public function OnAbilityActivate(ActivatedAbility : unreal.gameplayabilities.UGameplayAbility) : Void;
  
  /**
    Wait until a new ability (of the same or different type) is activated. Only input based abilities will be counted unless IncludeTriggeredAbilities is true.
  **/
  @:ufunction(BlueprintCallable) static public function WaitForAbilityActivate(OwningAbility : unreal.gameplayabilities.UGameplayAbility, WithTag : unreal.gameplaytags.FGameplayTag, WithoutTag : unreal.gameplaytags.FGameplayTag, IncludeTriggeredAbilities : Bool = false, TriggerOnce : Bool = true) : unreal.gameplayabilities.UAbilityTask_WaitAbilityActivate;
  
  /**
    Wait until a new ability (of the same or different type) is activated. Only input based abilities will be counted unless IncludeTriggeredAbilities is true. Uses a tag requirements structure to filter abilities.
  **/
  @:ufunction(BlueprintCallable) static public function WaitForAbilityActivateWithTagRequirements(OwningAbility : unreal.gameplayabilities.UGameplayAbility, TagRequirements : unreal.gameplayabilities.FGameplayTagRequirements, IncludeTriggeredAbilities : Bool = false, TriggerOnce : Bool = true) : unreal.gameplayabilities.UAbilityTask_WaitAbilityActivate;
  
  /**
    Wait until a new ability (of the same or different type) is activated. Only input based abilities will be counted unless IncludeTriggeredAbilities is true.
  **/
  @:ufunction(BlueprintCallable) static public function WaitForAbilityActivate_Query(OwningAbility : unreal.gameplayabilities.UGameplayAbility, Query : unreal.gameplaytags.FGameplayTagQuery, IncludeTriggeredAbilities : Bool = false, TriggerOnce : Bool = true) : unreal.gameplayabilities.UAbilityTask_WaitAbilityActivate;
  
}
