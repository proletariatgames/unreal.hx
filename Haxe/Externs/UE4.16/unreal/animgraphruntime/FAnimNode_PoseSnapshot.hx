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
  Provide a snapshot pose, either from the internal named pose cache or via a supplied snapshot
**/
@:umodule("AnimGraphRuntime")
@:glueCppIncludes("AnimNodes/AnimNode_PoseSnapshot.h")
@:uextern @:ustruct extern class FAnimNode_PoseSnapshot extends unreal.FAnimNode_Base {
  
  /**
    Snapshot to use. This should be populated at first by calling SnapshotPose
  **/
  @:uproperty public var Snapshot : unreal.FPoseSnapshot;
  
  /**
    The name of the snapshot previously stored with SavePoseSnapshot
  **/
  @:uproperty public var SnapshotName : unreal.FName;
  
  /**
    How to access the snapshot
  **/
  @:uproperty public var Mode : unreal.animgraphruntime.ESnapshotSourceMode;
  
}