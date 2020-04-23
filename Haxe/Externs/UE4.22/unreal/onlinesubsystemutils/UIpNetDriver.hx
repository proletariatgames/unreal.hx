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
package unreal.onlinesubsystemutils;

@:umodule("OnlineSubsystemUtils")
@:glueCppIncludes("IpNetDriver.h")
@:uextern @:uclass extern class UIpNetDriver extends unreal.UNetDriver {
  
  /**
    Number of ports which will be tried if current one is not available for binding (i.e. if told to bind to port N, will try from N to N+MaxPortCountToTry inclusive)
  **/
  @:uproperty public var MaxPortCountToTry : unreal.FakeUInt32;
  
  /**
    Does the game allow clients to remain after receiving ICMP port unreachable errors (handles flakey connections)
  **/
  @:uproperty public var AllowPlayerPortUnreach : Bool;
  
  /**
    Should port unreachable messages be logged
  **/
  @:uproperty public var LogPortUnreach : Bool;
  
}