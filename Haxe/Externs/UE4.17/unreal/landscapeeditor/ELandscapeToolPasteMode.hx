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
package unreal.landscapeeditor;

@:umodule("LandscapeEditor")
@:glueCppIncludes("Public/LandscapeEditorObject.h")
@:uname("ELandscapeToolPasteMode.Type")
@:uextern @:uenum extern enum ELandscapeToolPasteMode {
  
  /**
    Paste may both raise and lower values
  **/
  Both;
  
  /**
    Paste may only raise values, places where the pasted data would be below the heightmap are left unchanged. Good for copy/pasting mountains
  **/
  Raise;
  
  /**
    Paste may only lower values, places where the pasted data would be above the heightmap are left unchanged. Good for copy/pasting valleys or pits
  **/
  Lower;
  
}