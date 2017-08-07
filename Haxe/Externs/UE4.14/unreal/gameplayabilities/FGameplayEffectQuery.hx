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
  Every set condition within this query must match in order for the query to match. i.e. individual query elements are ANDed together.
**/
@:umodule("GameplayAbilities")
@:glueCppIncludes("GameplayEffect.h")
@:uextern @:ustruct extern class FGameplayEffectQuery {
  
  /**
    Matches on GameplayEffects with this definition
  **/
  @:uproperty public var EffectDefinition : unreal.TSubclassOf<unreal.gameplayabilities.UGameplayEffect>;
  
  /**
    Matches on GameplayEffects which come from this source
  **/
  @:uproperty public var EffectSource : unreal.UObject;
  
  /**
    Matches on GameplayEffects which modify given attribute.
  **/
  @:uproperty public var ModifyingAttribute : unreal.gameplayabilities.FGameplayAttribute;
  
  /**
    Query that is matched against tags the source of this GE has
  **/
  @:uproperty public var SourceTagQuery : unreal.gameplaytags.FGameplayTagQuery;
  
  /**
    Query that is matched against tags this GE has
  **/
  @:uproperty public var EffectTagQuery : unreal.gameplaytags.FGameplayTagQuery;
  
  /**
    Query that is matched against tags this GE gives
  **/
  @:uproperty public var OwningTagQuery : unreal.gameplaytags.FGameplayTagQuery;
  
}