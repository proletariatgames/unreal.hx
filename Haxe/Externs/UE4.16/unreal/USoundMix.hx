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
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:glueCppIncludes("Sound/SoundMix.h")
@:uextern @:uclass extern class USoundMix extends unreal.UObject {
  #if WITH_EDITORONLY_DATA
  
  /**
    Transient property used to trigger real-time updates of the active EQ filter for editor previewing
  **/
  @:uproperty public var bChanged : Bool;
  #end // WITH_EDITORONLY_DATA
  
  /**
    Time taken in seconds for the mix to fade out.
  **/
  @:uproperty public var FadeOutTime : unreal.Float32;
  
  /**
    Duration of mix, negative means it will be applied until another mix is set.
  **/
  @:uproperty public var Duration : unreal.Float32;
  
  /**
    Time taken in seconds for the mix to fade in.
  **/
  @:uproperty public var FadeInTime : unreal.Float32;
  
  /**
    Initial delay in seconds before the the mix is applied.
  **/
  @:uproperty public var InitialDelay : unreal.Float32;
  
  /**
    Array of changes to be applied to groups.
  **/
  @:uproperty public var SoundClassEffects : unreal.TArray<unreal.FSoundClassAdjuster>;
  @:uproperty public var EQSettings : unreal.FAudioEQEffect;
  @:uproperty public var EQPriority : unreal.Float32;
  
  /**
    Whether to apply the EQ effect
  **/
  @:uproperty public var bApplyEQ : Bool;
  
}