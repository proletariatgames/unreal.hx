/**
   * 
   * WARNING! This file was autogenerated by: 
   *  _   _ _____     ___   _   _ __   __ 
   * | | | |  ___|   /   | | | | |\ \ / / 
   * | | | | |__    / /| | | |_| | \ V /  
   * | | | |  __|  / /_| | |  _  | /   \  
   * | |_| | |___  \___  | | | | |/ /^\ \ 
   *  \___/\____/      |_/ \_| |_/\/   \/ 
   * 
   * This file was autogenerated by UE4HaxeExternGenerator using UHT definitions. It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
   * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal;


/**
  WARNING: This type is defined as NoExport by UHT. It will be empty because of it
  
  
**/
@:glueCppIncludes("GameFramework/WorldSettings.h")
@:noCopy @:noEquals @:uextern extern class FMeshProxySettings {
  public var bPlaneNegativeHalfspace : Bool;
  public var AxisIndex : unreal.Int32;
  public var ClippingLevel : unreal.Float32;
  public var bUseClippingPlane : Bool;
  public var MergeDistance : unreal.Int32;
  
  /**
    Angle at which a hard edge is introduced between faces.
  **/
  public var HardAngleThreshold : unreal.Float32;
  
  /**
    Should Simplygon recalculate normals for the proxy mesh?
  **/
  public var bRecalculateNormals : Bool;
  @:deprecated public var bExportSpecularMap_DEPRECATED : Bool;
  @:deprecated public var bExportRoughnessMap_DEPRECATED : Bool;
  @:deprecated public var bExportMetallicMap_DEPRECATED : Bool;
  @:deprecated public var bExportNormalMap_DEPRECATED : Bool;
  @:deprecated public var TextureHeight_DEPRECATED : unreal.Int32;
  @:deprecated public var TextureWidth_DEPRECATED : unreal.Int32;
  
  /**
    Material simplification
  **/
  public var Material : unreal.FMaterialSimplificationSettings;
  
  /**
    Screen size of the resulting proxy mesh in pixel size
  **/
  public var ScreenSize : unreal.Int32;
  
}
