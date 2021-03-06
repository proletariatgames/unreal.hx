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
package unreal;

/**
  Contains data for a group of assets to import
**/
@:glueCppIncludes("AssetExportTask.h")
@:uextern @:uclass extern class UAssetExportTask extends unreal.UObject {
  
  /**
    Array of error messages encountered during exporter
  **/
  @:uproperty public var Errors : unreal.TArray<unreal.FString>;
  
  /**
    Exporter specific options
  **/
  @:uproperty public var Options : unreal.UObject;
  
  /**
    Array of objects to ignore exporting
  **/
  @:uproperty public var IgnoreObjectList : unreal.TArray<unreal.UObject>;
  
  /**
    Write even if file empty
  **/
  @:uproperty public var bWriteEmptyFiles : Bool;
  
  /**
    Save to a file archive
  **/
  @:uproperty public var bUseFileArchive : Bool;
  
  /**
    Unattended export
  **/
  @:uproperty public var bAutomated : Bool;
  
  /**
    Allow dialog prompts
  **/
  @:uproperty public var bPrompt : Bool;
  
  /**
    Replace identical files
  **/
  @:uproperty public var bReplaceIdentical : Bool;
  
  /**
    Export selected only
  **/
  @:uproperty public var bSelected : Bool;
  
  /**
    File to export as
  **/
  @:uproperty public var FileName : unreal.FString;
  
  /**
    Optional exporter, otherwise it will be determined automatically
  **/
  @:uproperty public var Exporter : unreal.UExporter;
  
  /**
    Asset to export
  **/
  @:uproperty public var Object : unreal.UObject;
  
}
