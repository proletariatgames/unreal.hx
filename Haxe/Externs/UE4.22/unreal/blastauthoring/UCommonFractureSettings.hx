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
package unreal.blastauthoring;

@:umodule("BlastAuthoring")
@:glueCppIncludes("MeshFractureSettings.h")
@:uextern @:uclass extern class UCommonFractureSettings extends unreal.UObject {
  
  /**
    Random number generator seed for repeatability
  **/
  @:uproperty public var RandomSeed : unreal.Int32;
  
  /**
    Cleanup mesh option
  **/
  @:uproperty public var RemoveIslands : Bool;
  
  /**
    Fracture mode
  **/
  @:uproperty public var FractureMode : unreal.blastauthoring.EMeshFractureMode;
  
  /**
    Delete Source mesh when fracturing & generating a Geometry Collection
  **/
  @:uproperty public var DeleteSourceMesh : Bool;
  
  /**
    Enable bone color mode
  **/
  @:uproperty public var ShowBoneColors : Bool;
  
  /**
    In Editor Fracture Viewing mode
  **/
  @:uproperty public var ViewMode : unreal.blastauthoring.EMeshFractureLevel;
  
}
