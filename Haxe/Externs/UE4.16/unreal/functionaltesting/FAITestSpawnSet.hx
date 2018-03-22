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
package unreal.functionaltesting;

@:umodule("FunctionalTesting")
@:glueCppIncludes("FunctionalAITest.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FAITestSpawnSet {
  
  /**
    location used for spawning if spawn info doesn't define one
  **/
  @:uproperty public var FallbackSpawnLocation : unreal.AActor;
  @:uproperty public var bEnabled : Bool;
  
  /**
    give the set a name to help identify it if need be
  **/
  @:uproperty public var Name : unreal.FName;
  
  /**
    what to spawn
  **/
  @:uproperty public var SpawnInfoContainer : unreal.TArray<unreal.functionaltesting.FAITestSpawnInfo>;
  
}