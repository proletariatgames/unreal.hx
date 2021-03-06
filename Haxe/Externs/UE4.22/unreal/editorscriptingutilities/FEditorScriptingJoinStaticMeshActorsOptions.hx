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
package unreal.editorscriptingutilities;

@:umodule("EditorScriptingUtilities")
@:glueCppIncludes("Public/EditorLevelLibrary.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FEditorScriptingJoinStaticMeshActorsOptions {
  
  /**
    Rename StaticMeshComponents based on source Actor's name.
  **/
  @:uproperty public var bRenameComponentsFromSource : Bool;
  
  /**
    Name of the new spawned Actor to replace the provided Actors.
  **/
  @:uproperty public var NewActorLabel : unreal.FString;
  
  /**
    Destroy the provided Actors after the operation.
  **/
  @:uproperty public var bDestroySourceActors : Bool;
  
}
