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
package unreal.mediaassets;

@:umodule("MediaAssets")
@:glueCppIncludes("FileMediaSource.h")
@:uextern @:uclass extern class UFileMediaSource extends unreal.mediaassets.UBaseMediaSource {
  
  /**
    Load entire media file into memory and play from there (if possible).
  **/
  @:uproperty public var PrecacheFile : Bool;
  
  /**
    The path to the media file to be played.
    
    @see SetFilePath
  **/
  @:uproperty public var FilePath : unreal.FString;
  
  /**
    Set the path to the media file that this source represents.
    
    Automatically converts full paths to media sources that reside in the
    Engine's or project's /Content/Movies directory into relative paths.
    
    @param Path The path to set.
    @see FilePath, GetFilePath
  **/
  @:ufunction(BlueprintCallable) @:final public function SetFilePath(Path : unreal.FString) : Void;
  
}
