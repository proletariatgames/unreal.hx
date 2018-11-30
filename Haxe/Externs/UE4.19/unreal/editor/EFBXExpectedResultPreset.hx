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
package unreal.editor;

/**
  Import mesh type
**/
@:umodule("UnrealEd")
@:glueCppIncludes("Public/Tests/FbxAutomationCommon.h")
@:uname("EFBXExpectedResultPreset")
@:uextern @:uenum extern enum EFBXExpectedResultPreset {
  
  /**
    Data should contain the number of error [int0].
  **/
  Error_Number;
  
  /**
    Data should contain the number of warning [int0].
  **/
  Warning_Number;
  
  /**
    Data should contain the number of static mesh created [int0].
  **/
  Created_Staticmesh_Number;
  
  /**
    Data should contain the number of skeletal mesh created [int0].
  **/
  Created_Skeletalmesh_Number;
  
  /**
    Data should contain the number of Material created [int0] under the target content folder.
  **/
  Materials_Created_Number;
  
  /**
    Data should be the slot index [int0], and the expected original imported material slot name [string0].
  **/
  Material_Slot_Imported_Name;
  
  /**
    Data should be the total number of vertex for all LOD [int0].
  **/
  Vertex_Number;
  
  /**
    Data should be the expected number of LOD [int0].
  **/
  Lod_Number;
  
  /**
    Data should be the LOD index [int0] and total number of vertex for lod [int1].
  **/
  Vertex_Number_Lod;
  
  /**
    Data should contain the number of Material indexed by the mesh [int0].
  **/
  Mesh_Materials_Number;
  
  /**
    Data should be the LOD index [int0] and the expected number of section for a mesh [int1].
  **/
  Mesh_LOD_Section_Number;
  
  /**
    Data should be the LOD index [int0], section index [int1] and the expected number of vertex [int2].
  **/
  Mesh_LOD_Section_Vertex_Number;
  
  /**
    Data should be the LOD index [int0], section index [int1] and the expected number of triangle [int2].
  **/
  Mesh_LOD_Section_Triangle_Number;
  
  /**
    Data should be the LOD index [int0], section index [int1] and the expected name of material [string0].
  **/
  Mesh_LOD_Section_Material_Name;
  
  /**
    Data should be the LOD index [int0], section index [int1] and the expected material index of mesh materials [int2].
  **/
  Mesh_LOD_Section_Material_Index;
  
  /**
    Data should be the LOD index [int0], section index [int1] and the expected original imported material slot name [string0].
  **/
  Mesh_LOD_Section_Material_Imported_Name;
  
  /**
    Data should be the LOD index [int0], vertex index [int1] and the expected position of the vertex X[float0] Y[float1] Z[float2].
  **/
  Mesh_LOD_Vertex_Position;
  
  /**
    Data should be the LOD index [int0], vertex index [int1] and the expected normal of the vertex X[float0] Y[float1] Z[float2].
  **/
  Mesh_LOD_Vertex_Normal;
  
  /**
    Data should be the LOD index [int0] and the number of UV channel [int1] for the specified LOD.
  **/
  LOD_UV_Channel_Number;
  
  /**
    Data should contain the number of bone created [int0].
  **/
  Bone_Number;
  
  /**
    Data should contain the bone index [int0] and a position xyz [float0 float1 float2] optionnaly you can pass a tolerance [float3].
  **/
  Bone_Position;
  
  /**
    Data should contain the Number of Frame [int0].
  **/
  Animation_Frame_Number;
  
  /**
    Data should contain the animation length [float0].
  **/
  Animation_Length;
  
}