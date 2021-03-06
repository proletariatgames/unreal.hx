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
package unreal.augmentedreality;

@:umodule("AugmentedReality")
@:glueCppIncludes("ARTrackable.h")
@:uextern @:uclass extern class UARTrackedGeometry extends unreal.UObject {
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetLocalToWorldTransform() : unreal.FTransform;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetLocalToTrackingTransform() : unreal.FTransform;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetTrackingState() : unreal.augmentedreality.EARTrackingState;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function IsTracked() : Bool;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetDebugName() : unreal.FName;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetLastUpdateFrameNumber() : unreal.Int32;
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetLastUpdateTimestamp() : unreal.Float32;
  @:uproperty private var TrackingState : unreal.augmentedreality.EARTrackingState;
  @:uproperty private var LocalToAlignedTrackingTransform : unreal.FTransform;
  @:uproperty private var LocalToTrackingTransform : unreal.FTransform;
  
}
