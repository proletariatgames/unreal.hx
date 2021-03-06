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
package unreal.vputilities;

@:umodule("VPUtilities")
@:glueCppIncludes("VPSettings.h")
@:uextern @:uclass extern class UVPSettings extends unreal.UObject {
  @:uproperty private var CommandLineRoles : unreal.gameplaytags.FGameplayTagContainer;
  
  /**
    The machine role(s) in a virtual production context.
    @note The role may be override via the command line, "-VPRole=[Role.SubRole1|Role.SubRole2]"
  **/
  @:uproperty private var Roles : unreal.gameplaytags.FGameplayTagContainer;
  
}
