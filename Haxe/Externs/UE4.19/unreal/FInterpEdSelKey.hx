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
  A group, associated with a particular  AActor  or set of Actors, which contains a set of InterpTracks for interpolating
  properties of the  AActor  over time.
  The Outer of an UInterpGroup is an InterpData.
**/
@:glueCppIncludes("Classes/Matinee/InterpGroup.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FInterpEdSelKey {
  @:uproperty public var UnsnappedPosition : unreal.Float32;
  @:uproperty public var KeyIndex : unreal.Int32;
  @:uproperty public var Track : unreal.UInterpTrack;
  @:uproperty public var Group : unreal.UInterpGroup;
  
}