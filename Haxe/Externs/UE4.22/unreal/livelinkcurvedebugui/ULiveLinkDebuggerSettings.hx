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
package unreal.livelinkcurvedebugui;

/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, some of its methods are inaccessible
  
  
**/
@:umodule("LiveLinkCurveDebugUI")
@:glueCppIncludes("LiveLinkDebuggerSettings.h")
@:noClass @:uextern @:uclass extern class ULiveLinkDebuggerSettings extends unreal.UObject {
  
  /**
    This multiplier is used on the Viewport Widget version (IE: In Game) as it needs to be slightly more aggresive then the PC version
  **/
  @:uproperty public var DPIScaleMultiplier : unreal.Float32;
  
  /**
    Color used when the CurveValueBar is at 1.0
  **/
  @:uproperty public var MaxBarColor : unreal.slatecore.FSlateColor;
  
  /**
    Color used when the CurveValue bar is at 0
  **/
  @:uproperty public var MinBarColor : unreal.slatecore.FSlateColor;
  
}
