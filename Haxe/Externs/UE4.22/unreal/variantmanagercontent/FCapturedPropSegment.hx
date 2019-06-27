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
package unreal.variantmanagercontent;

/**
  Describes one link in a full property path
  For array properties, a link might be the outer (e.g. AttachChildren, -1, None)
  while also it may be an inner (e.g. AttachChildren, 2, Cube)
  Doing this allows us to resolve components regardless of their order, which
  is important for handling component reordering and transient components (e.g.
  runtime billboard components, etc)
**/
@:umodule("VariantManagerContent")
@:glueCppIncludes("Public/PropertyValue.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FCapturedPropSegment {
  @:uproperty public var ComponentName : unreal.FString;
  @:uproperty public var PropertyIndex : unreal.Int32;
  @:uproperty public var PropertyName : unreal.FString;
  
}