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
package unreal.livelinkmessagebusframework;

@:umodule("LiveLinkMessageBusFramework")
@:glueCppIncludes("Public/LiveLinkMessages.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FLiveLinkSubjectFrameMessage {
  
  /**
    Incrementing time for interpolation
  **/
  @:uproperty public var Time : unreal.Float64;
  
  /**
    Subject MetaData for this frame
  **/
  @:uproperty public var MetaData : unreal.livelinkinterface.FLiveLinkMetaData;
  
  /**
    Curve data for this frame
  **/
  @:uproperty public var Curves : unreal.TArray<unreal.livelinkinterface.FLiveLinkCurveElement>;
  
  /**
    Bone Transform data for this frame
  **/
  @:uproperty public var Transforms : unreal.TArray<unreal.FTransform>;
  @:uproperty public var SubjectName : unreal.FName;
  
}