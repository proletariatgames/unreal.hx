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
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("UnrealEd")
@:glueCppIncludes("Builders/TetrahedronBuilder.h")
@:uextern @:uclass extern class UTetrahedronBuilder extends unreal.editor.UEditorBrushBuilder {
  @:uproperty public var GroupName : unreal.FName;
  
  /**
    How many iterations this sphere uses to tessellate its geometry
  **/
  @:uproperty public var SphereExtrapolation : unreal.Int32;
  
  /**
    The radius of this sphere
  **/
  @:uproperty public var Radius : unreal.Float32;
  
}
