/**
   * 
   * WARNING! This file was autogenerated by: 
   *  _   _ _____     ___   _   _ __   __ 
   * | | | |  ___|   /   | | | | |\ \ / / 
   * | | | | |__    / /| | | |_| | \ V /  
   * | | | |  __|  / /_| | |  _  | /   \  
   * | |_| | |___  \___  | | | | |/ /^\ \ 
   *  \___/\____/      |_/ \_| |_/\/   \/ 
   * 
   * This file was autogenerated by UE4HaxeExternGenerator using UHT definitions. It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
   * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.landscape;


/**
  WARNING: This type is defined as NoExport by UHT. It will be empty because of it
  
  Structure storing Layer Data for import
**/
@:umodule("Landscape")
@:glueCppIncludes("LandscapeProxy.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FLandscapeImportLayerInfo {
  #if WITH_EDITORONLY_DATA
  @:uproperty public var SourceFilePath : unreal.FString;
  @:uproperty public var LayerInfo : unreal.landscape.ULandscapeLayerInfoObject;
  @:uproperty public var LayerName : unreal.FName;
  #end // WITH_EDITORONLY_DATA
  
}