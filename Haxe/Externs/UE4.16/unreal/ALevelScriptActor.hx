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
  ALevelScriptActor is the base class for classes generated by
  ULevelScriptBlueprints. ALevelScriptActor instances are hidden actors that
  exist within a level, and can execute level-wide logic (operating on specific
  actor instances within the level). The level-script's functionality is defined
  inside the ULevelScriptBlueprint itself (using the blueprint's node-based
  interface).
  
  @see AActor
  @see https://docs.unrealengine.com/latest/INT/Engine/Blueprints/UserGuide/Types/LevelBlueprint/index.html
  @see ULevelScriptBlueprint
  @see https://docs.unrealengine.com/latest/INT/Engine/Blueprints/index.html
  @see UBlueprint
**/
@:glueCppIncludes("Engine/LevelScriptActor.h")
@:uextern @:uclass extern class ALevelScriptActor extends unreal.AActor {
  
  /**
    Tries to find an event named "EventName" on all other levels, and calls it
  **/
  @:ufunction public function RemoteEvent(EventName : unreal.FName) : Bool;
  
  /**
    Sets the cinematic mode on all PlayerControllers
    
    @param       bInCinematicMode        specify true if the player is entering cinematic mode; false if the player is leaving cinematic mode.
    @param       bHidePlayer                     specify true to hide the player's pawn (only relevant if bInCinematicMode is true)
    @param       bAffectsHUD                     specify true if we should show/hide the HUD to match the value of bCinematicMode
    @param       bAffectsMovement        specify true to disable movement in cinematic mode, enable it when leaving
    @param       bAffectsTurning         specify true to disable turning in cinematic mode or enable it when leaving
  **/
  @:ufunction public function SetCinematicMode(bCinematicMode : Bool, bHidePlayer : Bool = true, bAffectsHUD : Bool = true, bAffectsMovement : Bool = false, bAffectsTurning : Bool = false) : Void;
  
  /**
    @todo document
  **/
  @:ufunction public function LevelReset() : Void;
  
  /**
    Event called on world origin location changes
    
    @param       OldOriginLocation       Previous world origin location
    @param       NewOriginLocation       New world origin location
  **/
  @:ufunction public function WorldOriginLocationChanged(OldOriginLocation : unreal.FIntVector, NewOriginLocation : unreal.FIntVector) : Void;
  
}