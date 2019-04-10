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
package unreal.magicleapeyetracker;

@:umodule("MagicLeapEyeTracker")
@:glueCppIncludes("Public/MagicLeapEyeTrackerTypes.h")
@:uname("EMagicLeapEyeTrackingStatus")
@:class @:uextern @:uenum extern enum EMagicLeapEyeTrackingStatus {
  
  /**
    Not Connected
  **/
  @DisplayName("Not Connected")
  NotConnected;
  
  /**
    The eyetracker is not connected to UE4 for some reason. The tracker might not be plugged in, the game window is currently running on a screen without an eyetracker or is otherwise not available.
    @DisplayName Disabled
  **/
  @DisplayName("Disabled")
  Disabled;
  
  /**
    Eyetracking has been disabled by the user or developer.
    @DisplayName User Not Present
  **/
  @DisplayName("User Not Present")
  UserNotPresent;
  
  /**
    The eyetracker is running but has not yet detected a user.
    @DisplayName User Present
  **/
  @DisplayName("User Present")
  UserPresent;
  
  /**
    The eyetracker has detected a user and is actively tracking them. They appear not to be focusing on the game window at the moment however.
    @DisplayName User Present And Watching The Game Window
  **/
  @DisplayName("User Present And Watching The Game Window")
  UserPresentAndWatchingWindow;
  
}