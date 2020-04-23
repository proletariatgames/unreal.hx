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
package unreal.timesynth;

/**
  Struct using to define a time range for the time synth in quantized time units
**/
@:umodule("TimeSynth")
@:glueCppIncludes("Classes/TimeSynthComponent.h")
@:uextern @:ustruct extern class FTimeSynthTimeDef {
  
  /**
    The number of beats
  **/
  @:uproperty public var NumBeats : unreal.Int32;
  
  /**
    The number of bars
  **/
  @:uproperty public var NumBars : unreal.Int32;
  
}