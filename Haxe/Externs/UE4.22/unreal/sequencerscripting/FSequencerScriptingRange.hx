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
package unreal.sequencerscripting;

@:umodule("SequencerScripting")
@:glueCppIncludes("Private/SequencerScriptingRange.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FSequencerScriptingRange {
  @:uproperty public var InternalRate : unreal.FFrameRate;
  @:uproperty public var ExclusiveEnd : unreal.Int32;
  @:uproperty public var InclusiveStart : unreal.Int32;
  @:uproperty public var bHasEnd : Bool;
  @:uproperty public var bHasStart : Bool;
  
}
