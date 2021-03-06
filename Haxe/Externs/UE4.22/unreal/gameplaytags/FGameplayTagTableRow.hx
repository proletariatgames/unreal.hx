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
package unreal.gameplaytags;

/**
  Simple struct for a table row in the gameplay tag table and element in the ini list
**/
@:umodule("GameplayTags")
@:glueCppIncludes("Classes/GameplayTagsManager.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FGameplayTagTableRow extends unreal.FTableRowBase {
  
  /**
    Developer comment clarifying the usage of a particular tag, not user facing
  **/
  @:uproperty public var DevComment : unreal.FString;
  
  /**
    Tag specified in the table
  **/
  @:uproperty public var Tag : unreal.FName;
  
}
