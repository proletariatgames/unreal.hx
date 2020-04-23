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
package unreal.datasmithcontent;

@:umodule("DatasmithContent")
@:glueCppIncludes("Public/DatasmithImportOptions.h")
@:uextern @:ustruct extern class FDatasmithImportBaseOptions {
  @:uproperty public var StaticMeshOptions : unreal.datasmithcontent.FDatasmithStaticMeshImportOptions;
  @:uproperty public var AssetOptions : unreal.datasmithcontent.FDatasmithAssetImportOptions;
  
  /**
    Specifies whether or not to import cameras
  **/
  @:uproperty public var bIncludeCamera : Bool;
  
  /**
    Specifies whether or not to import lights
  **/
  @:uproperty public var bIncludeLight : Bool;
  
  /**
    Specifies whether or not to import materials and textures
  **/
  @:uproperty public var bIncludeMaterial : Bool;
  
  /**
    Specifies whether or not to import geometry
  **/
  @:uproperty public var bIncludeGeometry : Bool;
  
  /**
    Specifies where to put the content
  **/
  @:uproperty public var SceneHandling : unreal.datasmithcontent.EDatasmithImportScene;
  
}