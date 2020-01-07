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
package unreal.slateremote;

/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, some of its methods are inaccessible
  
  Implements the settings for the Slate Remote plug-in.
**/
@:umodule("SlateRemote")
@:glueCppIncludes("Private/Shared/SlateRemoteSettings.h")
@:noClass @:uextern @:uclass extern class USlateRemoteSettings extends unreal.UObject {
  
  /**
    The IP endpoint to listen to when the Remote Server runs in a game.
  **/
  @:uproperty public var GameServerEndpoint : unreal.FString;
  
  /**
    The IP endpoint to listen to when the Remote Server runs in the Editor.
  **/
  @:uproperty public var EditorServerEndpoint : unreal.FString;
  
  /**
    Whether the Slate Remote server is enabled.
  **/
  @:uproperty public var EnableRemoteServer : Bool;
  
}