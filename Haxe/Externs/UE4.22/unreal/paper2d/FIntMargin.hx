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
package unreal.paper2d;

/**
  Describes the space around a 2D area on an integer grid.
**/
@:umodule("Paper2D")
@:glueCppIncludes("Classes/IntMargin.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FIntMargin {
  
  /**
    Holds the margin to the bottom.
  **/
  @:uproperty public var Bottom : unreal.Int32;
  
  /**
    Holds the margin to the right.
  **/
  @:uproperty public var Right : unreal.Int32;
  
  /**
    Holds the margin to the top.
  **/
  @:uproperty public var Top : unreal.Int32;
  
  /**
    Holds the margin to the left.
  **/
  @:uproperty public var Left : unreal.Int32;
  
}