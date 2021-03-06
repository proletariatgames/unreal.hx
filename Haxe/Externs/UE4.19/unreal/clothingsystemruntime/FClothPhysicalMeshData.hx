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
package unreal.clothingsystemruntime;

/**
  Physical mesh data created during asset import or created from a skeletal mesh
**/
@:umodule("ClothingSystemRuntime")
@:glueCppIncludes("Public/Assets/ClothingAsset.h")
@:uextern @:ustruct extern class FClothPhysicalMeshData {
  
  /**
    Valid indices to use for self collisions (reduced set of Indices)
  **/
  @:uproperty public var SelfCollisionIndices : unreal.TArray<unreal.FakeUInt32>;
  
  /**
    Number of fixed verts in the simulation mesh (fixed verts are just skinned and do not simulate)
  **/
  @:uproperty public var NumFixedVerts : unreal.Int32;
  
  /**
    Maximum number of bone weights of any vetex
  **/
  @:uproperty public var MaxBoneWeights : unreal.Int32;
  
  /**
    Indices and weights for each vertex, used to skin the mesh to create the reference pose
  **/
  @:uproperty public var BoneData : unreal.TArray<unreal.clothingsystemruntime.FClothVertBoneData>;
  
  /**
    Inverse mass for each vertex in the physical mesh
  **/
  @:uproperty public var InverseMasses : unreal.TArray<unreal.Float32>;
  
  /**
    Strength of anim drive per-particle (spring driving particle back to skinned location
  **/
  @:uproperty public var AnimDriveMultipliers : unreal.TArray<unreal.Float32>;
  
  /**
    Radius of movement to allow for backstop movement
  **/
  @:uproperty public var BackstopRadiuses : unreal.TArray<unreal.Float32>;
  
  /**
    Distance along the plane of the surface that the particles can travel (separation constraint)
  **/
  @:uproperty public var BackstopDistances : unreal.TArray<unreal.Float32>;
  
  /**
    The distance that each vertex can move away from its reference (skinned) position
  **/
  @:uproperty public var MaxDistances : unreal.TArray<unreal.Float32>;
  
  /**
    Indices of the simulation mesh triangles
  **/
  @:uproperty public var Indices : unreal.TArray<unreal.FakeUInt32>;
  
  /**
    Normal at each vertex
  **/
  @:uproperty public var Normals : unreal.TArray<unreal.FVector>;
  
  /**
    Positions of each simulation vertex
  **/
  @:uproperty public var Vertices : unreal.TArray<unreal.FVector>;
  
}
