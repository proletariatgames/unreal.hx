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
package unreal.clothpainter;

/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, some of its methods are inaccessible
  
  Unique settings for the fill tool
**/
@:umodule("ClothPainter")
@:glueCppIncludes("Private/ClothPaintTools.h")
@:noClass @:uextern @:uclass extern class UClothPaintTool_FillSettings extends unreal.UObject {
  
  /**
    The value to fill all selected verts to
  **/
  @:uproperty public var FillValue : unreal.Float32;
  
  /**
    Threshold for fill operation, will keep filling until sampled verts aren't within this range of the original vertex
  **/
  @:uproperty public var Threshold : unreal.Float32;
  
}
