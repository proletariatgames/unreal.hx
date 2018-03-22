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
  Helper struct for creating sub tracks supported by this track
**/
@:glueCppIncludes("Classes/Matinee/InterpTrack.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FSupportedSubTrackInfo {
  
  /**
    Index into the any subtrack group this subtrack belongs to (can be -1 for no group)
  **/
  @:uproperty public var GroupIndex : unreal.Int32;
  
  /**
    The name of the subtrack
  **/
  @:uproperty public var SubTrackName : unreal.FString;
  
  /**
    The sub track class which is supported by this track
  **/
  @:uproperty public var SupportedClass : unreal.TSubclassOf<unreal.UInterpTrack>;
  
}