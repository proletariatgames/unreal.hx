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
package unreal.editor;

@:umodule("UnrealEd")
@:glueCppIncludes("Factories/FbxFactory.h")
@:uextern @:uclass extern class UFbxFactory extends unreal.editor.UFactory {
  
  /**
    Prevent garbage collection of original when overriding ImportUI property
  **/
  @:uproperty public var OriginalImportUI : unreal.editor.UFbxImportUI;
  @:uproperty public var ImportUI : unreal.editor.UFbxImportUI;
  
}
