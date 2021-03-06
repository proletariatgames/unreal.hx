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
package unreal.magicleap;

/**
  The PlanesComponent class manages requests for planes, processes the results and provides them to the calling system.
  The calling system is able request planes within a specified area.  Various other search criteria can be set via this
  class's public properties.  Planes requests are processed on a separate thread.  Once a planes request has been processed
  the calling system will be notified via an FPlaneResultDelegate broadcast.
**/
@:umodule("MagicLeap")
@:glueCppIncludes("PlanesComponent.h")
@:uextern @:uclass extern class UPlanesComponent extends unreal.USceneComponent {
  
  /**
    Ignore bounds when tracking planes.
  **/
  @:uproperty public var IgnoreBoundingVolume : Bool;
  
  /**
    The minimum area (in squared Unreal Units) of planes to be returned.
    This value cannot be lower than 400 (lower values will be capped to this minimum).
  **/
  @:uproperty public var MinPlaneArea : unreal.Float32;
  
  /**
    If EPlaneQueryFlags::IgnoreHoles is not a query flag then holes with a perimeter (in Unreal Units)
    smaller than this value will be ignored, and can be part of the plane.
  **/
  @:uproperty public var MinHolePerimeter : unreal.Float32;
  
  /**
    The maximum number of planes that should be returned in the result.
  **/
  @:uproperty public var MaxResults : unreal.Int32;
  
  /**
    Bounding box for searching planes in.
  **/
  @:uproperty public var SearchVolume : unreal.UBoxComponent;
  
  /**
    The flags to apply to this query. TODO: Should be a TSet but that is misbehaving in the editor.
  **/
  @:uproperty public var QueryFlags : unreal.TArray<unreal.magicleap.EPlaneQueryFlags>;
  
  /**
    Requests planes with the current value of QueryFlags, SearchVolume and MaxResults.
    @param UserData User data for this request. The same data will be included in the result for query identification.
    @param ResultDelegate Delegate which will be called when the planes result is ready.
    @returns True if the planes query was successfully placed, false otherwise.
  **/
  @:ufunction(BlueprintCallable) @:final public function RequestPlanes(UserData : unreal.Int32, ResultDelegate : unreal.Const<unreal.PRef<unreal.magicleap.FPlaneResultDelegate>>) : Bool;
  
}
