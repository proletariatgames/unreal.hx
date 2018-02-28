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
  Container for Animation Update Rate parameters.
  They are shared for all components of an Actor, so they can be updated in sync.
**/
@:glueCppIncludes("Classes/Engine/EngineTypes.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FAnimUpdateRateParameters {
  
  /**
    The bucket to use when deciding which counter to use to calculate shift values
  **/
  @:uproperty public var ShiftBucket : unreal.EUpdateRateShiftBucket;
  
  /**
    Max Evaluation Rate allowed for interpolation to be enabled. Beyond, interpolation will be turned off.
  **/
  @:uproperty public var MaxEvalRateForInterpolation : unreal.Int32;
  
  /**
    Array of MaxDistanceFactor to use for AnimUpdateRate when mesh is visible (rendered).
    MaxDistanceFactor is size on screen, as used by LODs
    Example:
                BaseVisibleDistanceFactorThesholds.Add(0.4f)
                BaseVisibleDistanceFactorThesholds.Add(0.2f)
    means:
                0 frame skip, MaxDistanceFactor > 0.4f
                1 frame skip, MaxDistanceFactor > 0.2f
                2 frame skip, MaxDistanceFactor > 0.0f
  **/
  @:uproperty public var BaseVisibleDistanceFactorThesholds : unreal.TArray<unreal.Float32>;
  
  /**
    Rate of animation evaluation when non rendered (off screen and dedicated servers).
    a value of 4 means evaluated 1 frame, then 3 frames skipped
  **/
  @:uproperty public var BaseNonRenderedUpdateRate : unreal.Int32;
  
  /**
    Total time of the last series of skipped updates
  **/
  @:uproperty public var AdditionalTime : unreal.Float32;
  
  /**
    Track time we have lost via skipping
  **/
  @:uproperty public var TickedPoseOffestTime : unreal.Float32;
  
  /**
    (This frame) animation evaluation should be skipped.
  **/
  @:uproperty public var bSkipEvaluation : Bool;
  
  /**
    (This frame) animation update should be skipped.
  **/
  @:uproperty public var bSkipUpdate : Bool;
  
  /**
    If set, LOD/Frameskip map will be queried with mesh's MinLodModel instead of current LOD (PredictedLODLevel)
  **/
  @:uproperty public var bShouldUseMinLod : Bool;
  
  /**
    Whether or not to use the defined LOD/Frameskip map instead of separate distance factor thresholds
  **/
  @:uproperty public var bShouldUseLodMap : Bool;
  
  /**
    When skipping a frame, should it be interpolated or frozen?
  **/
  @:uproperty public var bInterpolateSkippedFrames : Bool;
  
  /**
    How often animation will be evaluated. 1 = every frame, 2 = every 2 frames, etc.
    has to be a multiple of UpdateRate.
  **/
  @:uproperty public var EvaluationRate : unreal.Int32;
  
  /**
    How often animation will be updated/ticked. 1 = every frame, 2 = every 2 frames, etc.
  **/
  @:uproperty public var UpdateRate : unreal.Int32;
  
}