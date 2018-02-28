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
package unreal.animgraphruntime;

/**
  Information about each target in the PoseDriver
**/
@:umodule("AnimGraphRuntime")
@:glueCppIncludes("Public/AnimNodes/AnimNode_PoseDriver.h")
@:uextern @:ustruct extern class FPoseDriverTarget {
  
  /**
    Name of item to drive - depends on DriveOutput setting.
    If DriveOutput is DrivePoses, this should be the name of a pose in the assigned PoseAsset
    If DriveOutput is DriveCurves, this is the name of the curve (morph target, material param etc) to drive
  **/
  @:uproperty public var DrivenName : unreal.FName;
  
  /**
    Custom curve mapping to apply if bApplyCustomCurve is true
  **/
  @:uproperty public var CustomCurve : unreal.FRichCurve;
  
  /**
    If we should apply a custom curve mapping to how this target activates
  **/
  @:uproperty public var bApplyCustomCurve : Bool;
  
  /**
    Scale applied to this target's function - a larger value will activate this target sooner
  **/
  @:uproperty public var TargetScale : unreal.Float32;
  
  /**
    Rotation of this target
  **/
  @:uproperty public var TargetRotation : unreal.FRotator;
  
  /**
    Translation of this target
  **/
  @:uproperty public var BoneTransforms : unreal.TArray<unreal.animgraphruntime.FPoseDriverTransform>;
  
}