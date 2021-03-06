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
package unreal.qos;

/**
  Enum for possible QoS return codes
**/
@:umodule("Qos")
@:glueCppIncludes("Public/QosRegionManager.h")
@:uname("EQosCompletionResult")
@:class @:uextern @:uenum extern enum EQosCompletionResult {
  
  /**
    Incomplete, invalid result
  **/
  Invalid;
  
  /**
    QoS operation was successful
  **/
  Success;
  
  /**
    QoS operation ended in failure
  **/
  Failure;
  
  /**
    QoS operation was canceled
  **/
  Canceled;
  
}
