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
package unreal.timemanagement;

/**
  Base class for sources to be used for time synchronization.
  
  Subclasses don't need to directly contain data, nor provide access to the
  data in any way (although they may).
  
  Currently, Synchronization does not work on the subframe level.
**/
@:umodule("TimeManagement")
@:glueCppIncludes("TimeSynchronizationSource.h")
@:uextern @:uclass extern class UTimeSynchronizationSource extends unreal.UObject {
  
  /**
    An additional offset in frames (relative to this source's frame rate) that should used.
    This is mainly useful to help correct discrepancies between the reported Sample Times
    and how the samples actually line up relative to other sources.
  **/
  @:uproperty public var FrameOffset : unreal.Int32;
  
  /**
    Whether or not this source should be considered when establishing synchronization.
  **/
  @:uproperty public var bUseForSynchronization : Bool;
  
}