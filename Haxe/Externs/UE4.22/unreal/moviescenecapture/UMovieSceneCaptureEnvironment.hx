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
package unreal.moviescenecapture;

@:umodule("MovieSceneCapture")
@:glueCppIncludes("MovieSceneCaptureEnvironment.h")
@:uextern @:uclass extern class UMovieSceneCaptureEnvironment extends unreal.UObject {
  
  /**
    Get the frame number of the current capture
  **/
  @:ufunction(BlueprintCallable) static public function GetCaptureFrameNumber() : unreal.Int32;
  
  /**
    Get the total elapsed time of the current capture in seconds
  **/
  @:ufunction(BlueprintCallable) static public function GetCaptureElapsedTime() : unreal.Float32;
  
  /**
    Return true if there is any capture currently active (even in a warm-up state).
    Useful for checking whether to do certain operations in BeginPlay
  **/
  @:ufunction(BlueprintCallable) static public function IsCaptureInProgress() : Bool;
  
  /**
    Attempt to locate a capture protocol - may not be in a capturing state
  **/
  @:ufunction(BlueprintCallable) static public function FindImageCaptureProtocol() : unreal.moviescenecapture.UMovieSceneImageCaptureProtocolBase;
  
  /**
    Attempt to locate a capture protocol - may not be in a capturing state
  **/
  @:ufunction(BlueprintCallable) static public function FindAudioCaptureProtocol() : unreal.moviescenecapture.UMovieSceneAudioCaptureProtocolBase;
  
}
