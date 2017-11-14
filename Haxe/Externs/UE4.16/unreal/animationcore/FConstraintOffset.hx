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
package unreal.animationcore;

/**
  individual component is saving different delta
  and they accumulate different
**/
@:umodule("AnimationCore")
@:glueCppIncludes("Constraint.h")
@:uextern @:ustruct extern class FConstraintOffset {
  @:uproperty public var Parent : unreal.FTransform;
  @:uproperty public var Scale : unreal.FVector;
  @:uproperty public var Rotation : unreal.FQuat;
  @:uproperty public var Translation : unreal.FVector;
  
}