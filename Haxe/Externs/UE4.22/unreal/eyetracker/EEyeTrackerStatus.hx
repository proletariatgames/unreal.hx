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
package unreal.eyetracker;

@:umodule("EyeTracker")
@:glueCppIncludes("Public/EyeTrackerTypes.h")
@:uname("EEyeTrackerStatus")
@:class @:uextern @:uenum extern enum EEyeTrackerStatus {
  
  /**
    Eyetracking feature is not available (device not plugged in, etc)
  **/
  NotConnected;
  
  /**
    Eyetracking is operating, but eyes are not being tracked
  **/
  NotTracking;
  
  /**
    Eyetracking is operating and eyes are being tracked
  **/
  Tracking;
  
}