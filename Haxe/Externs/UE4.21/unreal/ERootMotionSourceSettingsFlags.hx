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
  Enumeration for RootMotionSource settings
**/
@:glueCppIncludes("Classes/GameFramework/RootMotionSource.h")
@:uname("ERootMotionSourceSettingsFlags")
@:class @:uextern @:uenum extern enum ERootMotionSourceSettingsFlags {
  
  /**
    Source will switch character to Falling mode with any "Z up" velocity added.
    Use this for jump-like root motion. If not enabled, uses default jump impulse
    detection (which keeps you stuck on ground in Walking fairly strongly)
  **/
  UseSensitiveLiftoffCheck;
  
  /**
    If Duration of Source would end partway through the last tick it is active,
    do not reduce SimulationTime. Disabling this is useful for sources that
    are more about providing velocity (like jumps), vs. sources that need
    the precision of partial ticks for say ending up at an exact location (MoveTo)
  **/
  DisablePartialEndTick;
  
}