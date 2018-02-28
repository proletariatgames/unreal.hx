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
package unreal.oculushmd;

@:umodule("OculusHMD")
@:glueCppIncludes("OculusFunctionLibrary.h")
@:uextern @:uclass extern class UOculusFunctionLibrary extends unreal.UBlueprintFunctionLibrary {
  
  /**
    Grabs the current orientation and position for the HMD.  If positional tracking is not available, DevicePosition will be a zero vector
    
    @param DeviceRotation        (out) The device's current rotation
    @param DevicePosition        (out) The device's current position, in its own tracking space
    @param NeckPosition          (out) The estimated neck position, calculated using NeckToEye vector from User Profile. Same coordinate space as DevicePosition.
    @param bUseOrienationForPlayerCamera (in) Should be set to 'true' if the orientation is going to be used to update orientation of the camera manually.
    @param bUsePositionForPlayerCamera   (in) Should be set to 'true' if the position is going to be used to update position of the camera manually.
    @param PositionScale         (in) The 3D scale that will be applied to position.
  **/
  @:ufunction(BlueprintCallable) static public function GetPose(DeviceRotation : unreal.PRef<unreal.FRotator>, DevicePosition : unreal.PRef<unreal.FVector>, NeckPosition : unreal.PRef<unreal.FVector>, bUseOrienationForPlayerCamera : Bool = false, bUsePositionForPlayerCamera : Bool = false, PositionScale : unreal.Const<unreal.FVector>) : Void;
  
  /**
    Reports raw sensor data. If HMD doesn't support any of the parameters then it will be set to zero.
    
    @param AngularAcceleration    (out) Angular acceleration in radians per second per second.
    @param LinearAcceleration             (out) Acceleration in meters per second per second.
    @param AngularVelocity                (out) Angular velocity in radians per second.
    @param LinearVelocity                 (out) Velocity in meters per second.
    @param TimeInSeconds                  (out) Time when the reported IMU reading took place, in seconds.
  **/
  @:ufunction(BlueprintCallable) static public function GetRawSensorData(AngularAcceleration : unreal.PRef<unreal.FVector>, LinearAcceleration : unreal.PRef<unreal.FVector>, AngularVelocity : unreal.PRef<unreal.FVector>, LinearVelocity : unreal.PRef<unreal.FVector>, TimeInSeconds : unreal.Float32, @:opt("HMD") DeviceType : unreal.oculushmd.ETrackedDeviceType) : Void;
  
  /**
    Returns if the device is currently tracked by the runtime or not.
  **/
  @:ufunction(BlueprintCallable) static public function IsDeviceTracked(DeviceType : unreal.oculushmd.ETrackedDeviceType) : Bool;
  
  /**
    Returns if the device is currently tracked by the runtime or not.
  **/
  @:ufunction(BlueprintCallable) static public function SetCPUAndGPULevels(CPULevel : unreal.Int32, GPULevel : unreal.Int32) : Void;
  
  /**
    Returns current user profile.
    
    @param Profile                (out) Structure to hold current user profile.
    @return (boolean)     True, if user profile was acquired.
  **/
  @:ufunction(BlueprintCallable) static public function GetUserProfile(Profile : unreal.PRef<unreal.oculushmd.FHmdUserProfile>) : Bool;
  
  /**
    Sets 'base rotation' - the rotation that will be subtracted from
    the actual HMD orientation.
    Sets base position offset (in meters). The base position offset is the distance from the physical (0, 0, 0) position
    to current HMD position (bringing the (0, 0, 0) point to the current HMD position)
    Note, this vector is set by ResetPosition call; use this method with care.
    The axis of the vector are the same as in Unreal: X - forward, Y - right, Z - up.
    
    @param Rotation                       (in) Rotator object with base rotation
    @param BaseOffsetInMeters (in) the vector to be set as base offset, in meters.
    @param Options                        (in) specifies either position, orientation or both should be set.
  **/
  @:ufunction(BlueprintCallable) static public function SetBaseRotationAndBaseOffsetInMeters(Rotation : unreal.FRotator, BaseOffsetInMeters : unreal.FVector, Options : unreal.headmounteddisplay.EOrientPositionSelector) : Void;
  
  /**
    Returns current base rotation and base offset.
    The base offset is currently used base position offset, previously set by the
    ResetPosition or SetBasePositionOffset calls. It represents a vector that translates the HMD's position
    into (0,0,0) point, in meters.
    The axis of the vector are the same as in Unreal: X - forward, Y - right, Z - up.
    
    @param OutRotation                    (out) Rotator object with base rotation
    @param OutBaseOffsetInMeters  (out) base position offset, vector, in meters.
  **/
  @:ufunction(BlueprintCallable) static public function GetBaseRotationAndBaseOffsetInMeters(OutRotation : unreal.PRef<unreal.FRotator>, OutBaseOffsetInMeters : unreal.PRef<unreal.FVector>) : Void;
  
  /**
    Scales the HMD position that gets added to the virtual camera position.
    
    @param PosScale3D    (in) the scale to apply to the HMD position.
  **/
  @:ufunction(BlueprintCallable) static public function SetPositionScale3D(PosScale3D : unreal.FVector) : Void;
  
  /**
    Sets 'base rotation' - the rotation that will be subtracted from
    the actual HMD orientation.
    The position offset might be added to current HMD position,
    effectively moving the virtual camera by the specified offset. The addition
    occurs after the HMD orientation and position are applied.
    
    @param BaseRot                       (in) Rotator object with base rotation
    @param PosOffset                     (in) the vector to be added to HMD position.
    @param Options                       (in) specifies either position, orientation or both should be set.
  **/
  @:ufunction(BlueprintCallable) static public function SetBaseRotationAndPositionOffset(BaseRot : unreal.FRotator, PosOffset : unreal.FVector, Options : unreal.headmounteddisplay.EOrientPositionSelector) : Void;
  
  /**
    Returns current base rotation and position offset.
    
    @param OutRot                        (out) Rotator object with base rotation
    @param OutPosOffset          (out) the vector with previously set position offset.
  **/
  @:ufunction(BlueprintCallable) static public function GetBaseRotationAndPositionOffset(OutRot : unreal.PRef<unreal.FRotator>, OutPosOffset : unreal.PRef<unreal.FVector>) : Void;
  
  /**
    Adds loading splash screen with parameters
    
    @param Texture                       (in) A texture asset to be used for the splash. GearVR uses it as a path for loading icon; all other params are currently ignored by GearVR.
    @param TranslationInMeters (in) Initial translation of the center of the splash screen (in meters).
    @param Rotation                      (in) Initial rotation of the splash screen, with the origin at the center of the splash screen.
    @param SizeInMeters          (in) Size, in meters, of the quad with the splash screen.
    @param DeltaRotation         (in) Incremental rotation, that is added each 2nd frame to the quad transform. The quad is rotated around the center of the quad.
    @param bClearBeforeAdd       (in) If true, clears splashes before adding a new one.
  **/
  @:ufunction(BlueprintCallable) static public function AddLoadingSplashScreen(Texture : unreal.UTexture2D, TranslationInMeters : unreal.FVector, Rotation : unreal.FRotator, @:opt("(X=1.000,Y=1.000)") SizeInMeters : unreal.FVector2D, DeltaRotation : unreal.FRotator, bClearBeforeAdd : Bool = false) : Void;
  
  /**
    Removes all the splash screens.
  **/
  @:ufunction(BlueprintCallable) static public function ClearLoadingSplashScreens() : Void;
  
  /**
    Shows loading splash screen.
  **/
  @:ufunction(BlueprintCallable) static public function ShowLoadingSplashScreen() : Void;
  
  /**
    Hides loading splash screen.
    
    @param       bClear  (in) Clear all splash screens after hide.
  **/
  @:ufunction(BlueprintCallable) static public function HideLoadingSplashScreen(bClear : Bool = false) : Void;
  
  /**
    Enables/disables splash screen to be automatically shown when LoadMap is called.
    
    @param       bAutoShowEnabled        (in)    True, if automatic showing of splash screens is enabled when map is being loaded.
  **/
  @:ufunction(BlueprintCallable) static public function EnableAutoLoadingSplashScreen(bAutoShowEnabled : Bool) : Void;
  
  /**
    Returns true, if the splash screen is automatically shown when LoadMap is called.
  **/
  @:ufunction(BlueprintCallable) static public function IsAutoLoadingSplashScreenEnabled() : Bool;
  
  /**
    Sets a texture for loading icon mode and shows it. This call will clear all the splashes.
  **/
  @:ufunction(BlueprintCallable) static public function ShowLoadingIcon(Texture : unreal.UTexture2D) : Void;
  
  /**
    Clears the loading icon. This call will clear all the splashes.
  **/
  @:ufunction(BlueprintCallable) static public function HideLoadingIcon() : Void;
  
  /**
    Returns true, if the splash screen is in loading icon mode.
  **/
  @:ufunction(BlueprintCallable) static public function IsLoadingIconEnabled() : Bool;
  
  /**
    Sets loading splash screen parameters.
    
    @param TexturePath           (in) A path to the texture asset to be used for the splash. GearVR uses it as a path for loading icon; all other params are currently ignored by GearVR.
    @param DistanceInMeters      (in) Distance, in meters, to the center of the splash screen.
    @param SizeInMeters          (in) Size, in meters, of the quad with the splash screen.
    @param RotationAxes          (in) A vector that specifies the axis of the splash screen rotation (if RotationDelta is specified).
    @param RotationDeltaInDeg (in) Rotation delta, in degrees, that is added each 2nd frame to the quad transform. The quad is rotated around the vector "RotationAxes".
  **/
  @:ufunction(BlueprintCallable) static public function SetLoadingSplashParams(TexturePath : unreal.FString, DistanceInMeters : unreal.FVector, SizeInMeters : unreal.FVector2D, RotationAxis : unreal.FVector, RotationDeltaInDeg : unreal.Float32) : Void;
  
  /**
    Returns loading splash screen parameters.
    
    @param TexturePath           (out) A path to the texture asset to be used for the splash. GearVR uses it as a path for loading icon; all other params are currently ignored by GearVR.
    @param DistanceInMeters      (out) Distance, in meters, to the center of the splash screen.
    @param SizeInMeters          (out) Size, in meters, of the quad with the splash screen.
    @param RotationAxes          (out) A vector that specifies the axis of the splash screen rotation (if RotationDelta is specified).
    @param RotationDeltaInDeg (out) Rotation delta, in degrees, that is added each 2nd frame to the quad transform. The quad is rotated around the vector "RotationAxes".
  **/
  @:ufunction(BlueprintCallable) static public function GetLoadingSplashParams(TexturePath : unreal.PRef<unreal.FString>, DistanceInMeters : unreal.PRef<unreal.FVector>, SizeInMeters : unreal.PRef<unreal.FVector2D>, RotationAxis : unreal.PRef<unreal.FVector>, RotationDeltaInDeg : unreal.Float32) : Void;
  
}