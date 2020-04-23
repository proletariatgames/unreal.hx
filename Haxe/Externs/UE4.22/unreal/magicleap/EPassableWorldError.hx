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
package unreal.magicleap;

/**
  List of possible error values for MagicLeapARPin fucntions.
**/
@:umodule("MagicLeap")
@:glueCppIncludes("Classes/MagicLeapARPinComponent.h")
@:uname("EPassableWorldError")
@:class @:uextern @:uenum extern enum EPassableWorldError {
  
  /**
    No error.
  **/
  None;
  
  /**
    Map quality too low for content persistence. Continue building the map.
  **/
  LowMapQuality;
  
  /**
    Currently unable to localize into any map. Continue building the map.
  **/
  UnableToLocalize;
  
  /**
    AR Pin is not available at this time.
  **/
  Unavailable;
  
  /**
    Privileges not met. Add 'PwFoundObjRead' privilege to app manifest and request it at runtime.
  **/
  PrivilegeDenied;
  
  /**
    Invalid function parameter.
  **/
  InvalidParam;
  
  /**
    Unspecified error.
  **/
  UnspecifiedFailure;
  
  /**
    Privilege has been requested but not yet granted by the user.
  **/
  PrivilegeRequestPending;
  
}