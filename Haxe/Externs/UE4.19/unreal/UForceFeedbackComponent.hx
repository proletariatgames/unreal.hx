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
  ForceFeedbackComponent allows placing a rumble effect in to the world and having it apply to player characters who come near it
**/
@:glueCppIncludes("Components/ForceFeedbackComponent.h")
@:uextern @:uclass extern class UForceFeedbackComponent extends unreal.USceneComponent {
  
  /**
    called when we finish playing audio, either because it played to completion or because a Stop() call turned it off early
  **/
  @:uproperty public var OnForceFeedbackFinished : unreal.FOnForceFeedbackFinished;
  
  /**
    If bOverrideSettings is true, the attenuation properties to use for effects generated by this component
  **/
  @:uproperty public var AttenuationOverrides : unreal.FForceFeedbackAttenuationSettings;
  
  /**
    If bOverrideSettings is false, the asset to use to determine attenuation properties for effects generated by this component
  **/
  @:uproperty public var AttenuationSettings : unreal.UForceFeedbackAttenuation;
  
  /**
    The intensity multiplier to apply to effects generated by this component
  **/
  @:uproperty public var IntensityMultiplier : unreal.Float32;
  
  /**
    Should the Attenuation Settings asset be used (false) or should the properties set directly on the component be used for attenuation properties
  **/
  @:uproperty public var bOverrideAttenuation : Bool;
  
  /**
    Should the playback of the forcefeedback pattern ignore time dilation and use the app's delta time
  **/
  @:uproperty public var bIgnoreTimeDilation : Bool;
  @:uproperty public var bLooping : Bool;
  
  /**
    Stop effect when owner is destroyed
  **/
  @:uproperty public var bStopWhenOwnerDestroyed : Bool;
  
  /**
    Auto destroy this component on completion
  **/
  @:uproperty public var bAutoDestroy : Bool;
  
  /**
    The feedback effect to be played
  **/
  @:uproperty public var ForceFeedbackEffect : unreal.UForceFeedbackEffect;
  
  /**
    Set what force feedback effect is played by this component
  **/
  @:ufunction(BlueprintCallable) @:final public function SetForceFeedbackEffect(NewForceFeedbackEffect : unreal.UForceFeedbackEffect) : Void;
  
  /**
    Start a feedback effect playing
  **/
  @:ufunction(BlueprintCallable) public function Play(StartTime : unreal.Float32 = 0.000000) : Void;
  
  /**
    Stop playing the feedback effect
  **/
  @:ufunction(BlueprintCallable) public function Stop() : Void;
  
  /**
    Set a new intensity multiplier
  **/
  @:ufunction(BlueprintCallable) @:final public function SetIntensityMultiplier(NewIntensityMultiplier : unreal.Float32) : Void;
  
  /**
    Modify the attenuation settings of the component
  **/
  @:ufunction(BlueprintCallable) @:final public function AdjustAttenuation(InAttenuationSettings : unreal.Const<unreal.PRef<unreal.FForceFeedbackAttenuationSettings>>) : Void;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function BP_GetAttenuationSettingsToApply(OutAttenuationSettings : unreal.PRef<unreal.FForceFeedbackAttenuationSettings>) : Bool;
  
}
