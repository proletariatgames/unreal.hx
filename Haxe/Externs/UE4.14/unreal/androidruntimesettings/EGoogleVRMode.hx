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
package unreal.androidruntimesettings;

@:umodule("AndroidRuntimeSettings")
@:glueCppIncludes("AndroidRuntimeSettings.h")
@:uname("EGoogleVRMode.Type")
@:uextern @:uenum extern enum EGoogleVRMode {
  
  /**
    Configure GoogleVR to run in Cardboard-only mode.
    @DisplayName Cardboard
  **/
  @DisplayName("Cardboard")
  Cardboard;
  
  /**
    Configure GoogleVR to run in Daydream-only mode. In this mode, app won't be able to run on Non Daydream-ready phone.
    @DisplayName Daydream
  **/
  @DisplayName("Daydream")
  Daydream;
  
  /**
    Configure GoogleVR to run in Daydream mode on Daydream-ready phone and fallback to Cardboard mode on Non Daydream-ready phone.
    @DisplayName Daydream & Cardboard
  **/
  @DisplayName("Daydream & Cardboard")
  DaydreamAndCardboard;
  
}