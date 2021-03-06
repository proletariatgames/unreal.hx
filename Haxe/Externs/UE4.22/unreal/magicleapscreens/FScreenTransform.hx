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
package unreal.magicleapscreens;

/**
  Information required to place a screen in the world.
  
  This will be received from the Screens Launcher api, based on the previous screens spawned by user.
**/
@:umodule("MagicLeapScreens")
@:glueCppIncludes("Public/MagicLeapScreensTypes.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FScreenTransform {
  
  /**
    Dimensions of the screen in Unreal Units. The dimensions are axis-aligned with the orientation.
  **/
  @:uproperty public var ScreenDimensions : unreal.FVector;
  
  /**
    Orientation of the screen in Unreal's world space.
  **/
  @:uproperty public var ScreenOrientation : unreal.FRotator;
  
  /**
    Position of the screen in Unreal's world space.
  **/
  @:uproperty public var ScreenPosition : unreal.FVector;
  
}
