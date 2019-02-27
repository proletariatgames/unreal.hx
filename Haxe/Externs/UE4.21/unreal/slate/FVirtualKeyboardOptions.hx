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
package unreal.slate;

@:umodule("Slate")
@:glueCppIncludes("Public/Widgets/Input/IVirtualKeyboardEntry.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FVirtualKeyboardOptions {
  
  /**
    Enables autocorrect for this widget, if supported by the platform's virtual keyboard. Autocorrect must also be enabled in Input settings for this to take effect.
  **/
  @:uproperty public var bEnableAutocorrect : Bool;
  
}