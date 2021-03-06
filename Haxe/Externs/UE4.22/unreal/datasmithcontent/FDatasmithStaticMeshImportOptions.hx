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
@:uextern @:ustruct extern class FDatasmithStaticMeshImportOptions {
  @:uproperty public var bRemoveDegenerates : Bool;
  @:uproperty public var bGenerateLightmapUVs : Bool;
  
  /**
    Maximum resolution for auto-generated lightmap UVs
  **/
  @:uproperty public var MaxLightmapResolution : unreal.datasmithcontent.EDatasmithImportLightmapMax;
  
  /**
    Minimum resolution for auto-generated lightmap UVs
  **/
  @:uproperty public var MinLightmapResolution : unreal.datasmithcontent.EDatasmithImportLightmapMin;
  
}
