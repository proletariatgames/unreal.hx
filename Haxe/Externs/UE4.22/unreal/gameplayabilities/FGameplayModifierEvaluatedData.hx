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
  Data that describes what happened in an attribute modification. This is passed to ability set callbacks
**/
@:umodule("GameplayAbilities")
@:glueCppIncludes("Public/GameplayEffectTypes.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FGameplayModifierEvaluatedData {
  
  /**
    True if something was evaluated
  **/
  @:uproperty public var IsValid : Bool;
  
  /**
    Handle of the active gameplay effect that originated us. Will be invalid in many cases
  **/
  @:uproperty public var Handle : unreal.gameplayabilities.FActiveGameplayEffectHandle;
  
  /**
    The raw magnitude of the applied attribute, this is generally before being clamped
  **/
  @:uproperty public var Magnitude : unreal.Float32;
  
  /**
    The numeric operation of this modifier: Override, Add, Multiply, etc
  **/
  @:uproperty public var ModifierOp : unreal.gameplayabilities.EGameplayModOp;
  
  /**
    What attribute was modified
  **/
  @:uproperty public var Attribute : unreal.gameplayabilities.FGameplayAttribute;
  
}
