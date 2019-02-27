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
package unreal.automationmessages;

/**
  Implements a message that handles both storing and requesting ground truth data.
  for the first time this test is run, it might need to store things, or get things.
**/
@:umodule("AutomationMessages")
@:glueCppIncludes("Public/AutomationWorkerMessages.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FAutomationWorkerTestDataRequest {
  @:uproperty public var JsonData : unreal.FString;
  @:uproperty public var DataName : unreal.FString;
  @:uproperty public var DataTestName : unreal.FString;
  @:uproperty public var DataPlatform : unreal.FString;
  
  /**
    The category of the data, this is purely to bucket and separate the ground truth data we store into different directories.
  **/
  @:uproperty public var DataType : unreal.FString;
  
}