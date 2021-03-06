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
package unreal.synthesis;

@:umodule("Synthesis")
@:glueCppIncludes("Classes/SourceEffects/SourceEffectFoldbackDistortion.h")
@:uextern @:ustruct extern class FSourceEffectFoldbackDistortionSettings {
  
  /**
    The amount of gain to apply to the output
  **/
  @:uproperty public var OutputGainDb : unreal.Float32;
  
  /**
    If the audio amplitude is higher than this, it will fold back
  **/
  @:uproperty public var ThresholdDb : unreal.Float32;
  
  /**
    The amount of gain to add to input to allow forcing the triggering of the threshold
  **/
  @:uproperty public var InputGainDb : unreal.Float32;
  
}
