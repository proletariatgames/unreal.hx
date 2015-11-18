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
package unreal.editor;


/**
  Implements the Editor's play settings.
**/
@:umodule("UnrealEd")
@:glueCppIncludes("Settings/LevelEditorPlaySettings.h")
@:uextern extern class ULevelEditorPlaySettings extends unreal.UObject {
  
  /**
    Collection of common screen resolutions on television screens.
  **/
  public var TelevisionScreenResolutions : unreal.TArray<unreal.editor.FPlayScreenResolution>;
  
  /**
    Collection of common screen resolutions on tablet devices.
  **/
  public var TabletScreenResolutions : unreal.TArray<unreal.editor.FPlayScreenResolution>;
  
  /**
    Collection of common screen resolutions on mobile phones.
  **/
  public var PhoneScreenResolutions : unreal.TArray<unreal.editor.FPlayScreenResolution>;
  
  /**
    Collection of common screen resolutions on desktop monitors.
  **/
  public var MonitorScreenResolutions : unreal.TArray<unreal.editor.FPlayScreenResolution>;
  
  /**
    Collection of common screen resolutions on mobile phones.
  **/
  public var LaptopScreenResolutions : unreal.TArray<unreal.editor.FPlayScreenResolution>;
  
  /**
    The last type of play session the user ran.
  **/
  public var LastExecutedPlayModeType : unreal.editor.EPlayModeType;
  
  /**
    The last type of play location the user ran.
  **/
  public var LastExecutedPlayModeLocation : unreal.editor.EPlayModeLocations;
  
  /**
    The last type of play-on session the user ran.
  **/
  public var LastExecutedLaunchModeType : unreal.editor.ELaunchModeType;
  
  /**
    The name of the last device that the user ran a play session on.
  **/
  public var LastExecutedLaunchName : unreal.FString;
  
  /**
    The name of the last platform that the user ran a play session on.
  **/
  public var LastExecutedLaunchDevice : unreal.FString;
  
  /**
    The last known screen positions of multiple instance windows (in pixels).
  **/
  public var MultipleInstancePositions : unreal.TArray<unreal.FIntPoint>;
  
  /**
    The last used width for multiple instance windows (in pixels).
  **/
  public var MultipleInstanceLastWidth : unreal.Int32;
  
  /**
    The last used height for multiple instance windows (in pixels).
  **/
  public var MultipleInstanceLastHeight : unreal.Int32;
  
  /**
    Whether to automatically recompile dirty Blueprints before launching
  **/
  public var bAutoCompileBlueprintsOnLaunch : Bool;
  
  /**
    The width of the new view port window in pixels (0 = use the desktop's screen resolution).
  **/
  public var BuildGameBeforeLaunch : unreal.editor.EPlayOnBuildMode;
  
  /**
    Extra parameters to be include as part of the command line for the standalone game.
  **/
  public var AdditionalLaunchParameters : unreal.FString;
  
  /**
    Whether sound should be disabled when playing standalone games.
  **/
  public var DisableStandaloneSound : Bool;
  
  /**
    Whether the standalone game window should be centered on the screen.
  **/
  public var CenterStandaloneWindow : Bool;
  
  /**
    The position of the standalone game window on the screen in pixels.
  **/
  public var StandaloneWindowPosition : unreal.FIntPoint;
  
  /**
    The height of the standalone game window in pixels (0 = use the desktop's screen resolution).
  **/
  public var StandaloneWindowHeight : unreal.Int32;
  
  /**
    The width of the standalone game window in pixels (0 = use the desktop's screen resolution).
  **/
  public var StandaloneWindowWidth : unreal.Int32;
  
  /**
    Whether the new window should be centered on the screen.
  **/
  public var CenterNewWindow : Bool;
  
  /**
    The position of the new view port window on the screen in pixels.
  **/
  public var NewWindowPosition : unreal.FIntPoint;
  
  /**
    The height of the new view port window in pixels (0 = use the desktop's screen resolution).
  **/
  public var NewWindowHeight : unreal.Int32;
  
  /**
    The width of the new view port window in pixels (0 = use the desktop's screen resolution).
  **/
  public var NewWindowWidth : unreal.Int32;
  
  /**
    Always have the PIE window on top of the parent windows.
  **/
  public var PIEAlwaysOnTop : Bool;
  
  /**
    Prefer to stream sub-levels from the disk instead of duplicating editor sub-levels
  **/
  public var bPreferToStreamLevelsInPIE : Bool;
  
  /**
    True if Play In Editor should only load currently-visible levels in PIE.
  **/
  public var bOnlyLoadVisibleLevelsInPIE : Bool;
  
  /**
    Which quality level to use when playing in editor
  **/
  public var PlayInEditorSoundQualityLevel : unreal.Int32;
  
  /**
    Whether to play sounds when in a Play In Editor session
  **/
  public var EnableSound : Bool;
  
  /**
    Automatically recompile blueprints used by the current level when initiating a Play In Editor session
  **/
  public var AutoRecompileBlueprints : Bool;
  
  /**
    Whether or not HMD orientation should be used when playing in viewport
  **/
  public var ViewportGetsHMDControl : Bool;
  
  /**
    Location on screen to anchor the mouse control label when in PIE mode.
  **/
  public var MouseControlLabelPosition : unreal.editor.ELabelAnchorMode;
  
  /**
    Whether to show a label for mouse control gestures in the PIE view.
  **/
  public var ShowMouseControlLabel : Bool;
  
  /**
    Give the game mouse control when PIE starts or require a click in the viewport first
  **/
  public var GameGetsMouseControl : Bool;
  
  /**
    The PlayerStart class used when spawning the player at the current camera location.
  **/
  public var PlayFromHerePlayerStartClassName : unreal.FString;
  
}