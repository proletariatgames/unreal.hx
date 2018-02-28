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

/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, some of its methods are inaccessible
  
  This class is a wrapper for editor loading and saving functionality
  It is meant to contain only functions that can be executed in script (but are also allowed in C++).
  It is separated from FEditorFileUtils to ensure new easier to use methods can be created without breaking FEditorFileUtils backwards compatibility
  However this should be used in place of FEditorFileUtils wherever possible as the goal is to deprecate FEditorFileUtils eventually
**/
@:umodule("UnrealEd")
@:glueCppIncludes("FileHelpers.h")
@:noClass @:uextern @:uclass extern class UEditorLoadingAndSavingUtils extends unreal.UObject {
  @:ufunction(BlueprintCallable) static public function NewBlankMap(bSaveExistingMap : Bool) : unreal.UWorld;
  @:ufunction(BlueprintCallable) static public function NewMapFromTemplate(PathToTemplateLevel : unreal.FString, bSaveExistingMap : Bool) : unreal.UWorld;
  
  /**
    Prompts the user to save the current map if necessary, the presents a load dialog and
    loads a new map if selected by the user.
  **/
  @:ufunction(BlueprintCallable) static public function LoadMapWithDialog() : unreal.UWorld;
  
  /**
    Loads the specified map.  Does not prompt the user to save the current map.
    
    @param       Filename                Level package filename, including path.
    @return                                      true if the map was loaded successfully.
  **/
  @:ufunction(BlueprintCallable) static public function LoadMap(Filename : unreal.FString) : unreal.UWorld;
  
  /**
    Saves the specified map, returning true on success.
    
    @param       World                   The world to save.
    @param       AssetPath               The valid content directory path and name for the asset.  E.g "/Game/MyMap"
    
    @return                                      true if the map was saved successfully.
  **/
  @:ufunction(BlueprintCallable) static public function SaveMap(World : unreal.UWorld, AssetPath : unreal.FString) : Bool;
  
  /**
    Looks at all currently loaded packages and saves them if their "bDirty" flag is set, optionally prompting the user to select which packages to save)
    
    @param       bSaveMapPackages                        true if map packages should be saved
    @param       bSaveContentPackages            true if we should save content packages.
    @param       bPromptUserToSave                       true if we should prompt the user to save dirty packages we found and check them out from source control(if enabled). False to assume all dirty packages should be saved and checked out
    @return                                                              true on success, false on fail.
  **/
  @:ufunction(BlueprintCallable) static public function SaveDirtyPackages(bSaveMapPackages : Bool, bSaveContentPackages : Bool, bPromptUser : Bool) : Bool;
  
  /**
    Saves the active level, prompting the use for checkout if necessary.
    
    @return      true on success, False on fail
  **/
  @:ufunction(BlueprintCallable) static public function SaveCurrentLevel() : Bool;
  
  /**
    Appends array with all currently dirty map packages.
    
    @param OutDirtyPackages Array to append dirty packages to.
  **/
  @:ufunction(BlueprintCallable) static public function GetDirtyMapPackages(OutDirtyPackages : unreal.PRef<unreal.TArray<unreal.UPackage>>) : Void;
  
  /**
    Appends array with all currently dirty content packages.
    
    @param OutDirtyPackages Array to append dirty packages to.
  **/
  @:ufunction(BlueprintCallable) static public function GetDirtyContentPackages(OutDirtyPackages : unreal.PRef<unreal.TArray<unreal.UPackage>>) : Void;
  
  /**
    Imports a file such as (FBX or obj) and spawns actors f into the current level
  **/
  @:ufunction(BlueprintCallable) static public function ImportScene(Filename : unreal.FString) : Void;
  
  /**
    Exports the current scene
  **/
  @:ufunction(BlueprintCallable) static public function ExportScene(bExportSelectedActorsOnly : Bool) : Void;
  
}