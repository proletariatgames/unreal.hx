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
package unreal;

/**
  FSkeletalMeshOptimizationSettings - The settings used to optimize a skeletal mesh LOD.
**/
@:glueCppIncludes("Public/SkeletalMeshReductionSettings.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FSkeletalMeshOptimizationSettings {
  #if WITH_EDITORONLY_DATA
  @:deprecated @:uproperty public var BakePose_DEPRECATED : unreal.UAnimSequence;
  @:deprecated @:uproperty public var BonesToRemove_DEPRECATED : unreal.TArray<unreal.FBoneReference>;
  #end // WITH_EDITORONLY_DATA
  
  /**
    Base LOD index to generate this LOD. By default, we generate from LOD 0
  **/
  @:uproperty public var BaseLOD : unreal.Int32;
  
  /**
    Maximum number of bones that can be assigned to each vertex.
  **/
  @:uproperty public var MaxBonesPerVertex : unreal.Int32;
  
  /**
    If the angle between two triangles are above this value, the normals will not be
          smooth over the edge between those two triangles. Set in degrees. This is only used when bRecalcNormals is set to true
  **/
  @:uproperty public var NormalsThreshold : unreal.Float32;
  
  /**
    The welding threshold distance. Vertices under this distance will be welded.
  **/
  @:uproperty public var WeldingThreshold : unreal.Float32;
  
  /**
    Whether Normal smoothing groups should be preserved. If true then Hard Edge Angle (NormalsThreshold) is used *
  **/
  @:uproperty public var bRecalcNormals : Bool;
  
  /**
    Remap the morph targets from the base LOD onto the reduce LOD.
  **/
  @:uproperty public var bRemapMorphTargets : Bool;
  
  /**
    How important skinning quality is.
  **/
  @:uproperty public var SkinningImportance : unreal.SkeletalMeshOptimizationImportance;
  
  /**
    How important shading quality is.
  **/
  @:uproperty public var ShadingImportance : unreal.SkeletalMeshOptimizationImportance;
  
  /**
    How important texture density is.
  **/
  @:uproperty public var TextureImportance : unreal.SkeletalMeshOptimizationImportance;
  
  /**
    How important the shape of the geometry is.
  **/
  @:uproperty public var SilhouetteImportance : unreal.SkeletalMeshOptimizationImportance;
  
  /**
    The method to use when optimizing the skeletal mesh LOD
  **/
  @:uproperty public var ReductionMethod : unreal.SkeletalMeshOptimizationType;
  
  /**
    If ReductionMethod equals MaxDeviation this value is the maximum deviation from the base mesh as a percentage of the bounding sphere.
    In code, it ranges from [0, 1]. In the editor UI, it ranges from [0, 100]
  **/
  @:uproperty public var MaxDeviationPercentage : unreal.Float32;
  
  /**
    If ReductionMethod equals NumOfTriangles this value is the ratio of triangles percentage to remove from the mesh.
    In code, it ranges from [0, 1]. In the editor UI, it ranges from [0, 100]
  **/
  @:uproperty public var NumOfTrianglesPercentage : unreal.Float32;
  
}
