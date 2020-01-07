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
package unreal.gameplayabilities;

/**
  DataTable that allows us to define meta data about attributes. Still a work in progress.
**/
@:umodule("GameplayAbilities")
@:glueCppIncludes("Public/AttributeSet.h")
@:uextern @:ustruct extern class FAttributeMetaData extends unreal.FTableRowBase {
  @:uproperty public var bCanStack : Bool;
  @:uproperty public var DerivedAttributeInfo : unreal.FString;
  @:uproperty public var MaxValue : unreal.Float32;
  @:uproperty public var MinValue : unreal.Float32;
  @:uproperty public var BaseValue : unreal.Float32;
  
}