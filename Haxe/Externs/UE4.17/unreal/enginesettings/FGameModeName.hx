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
package unreal.enginesettings;

/**
  Helper structure, used to associate GameModes with shortcut names.
**/
@:umodule("EngineSettings")
@:glueCppIncludes("Classes/GameMapsSettings.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FGameModeName {
  
  /**
    GameMode class to load
  **/
  @:uproperty public var GameMode : unreal.FStringClassReference;
  
  /**
    Abbreviation/prefix that can be used as an alias for the class name
  **/
  @:uproperty public var Name : unreal.FString;
  
}