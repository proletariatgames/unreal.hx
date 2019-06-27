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
package unreal.significancemanager;

/**
  The significance manager provides a framework for registering objects by tag to each have a significance
  * value calculated from which a game specific subclass and game logic can make decisions about what level
  * of detail objects should be at, tick frequency, whether to spawn effects, and other such functionality
  *
  * Each object that is registered must have a corresponding unregister event or else a dangling Object reference will
  * be left resulting in an eventual crash once the Object has been garbage collected.
  *
  * Each user of the significance manager is expected to call the Update function from the appropriate location in the
  * game code.  GameViewportClient::Tick may often serve as a good place to do this.
**/
@:umodule("SignificanceManager")
@:glueCppIncludes("SignificanceManager.h")
@:uextern @:uclass extern class USignificanceManager extends unreal.UObject {
  
}