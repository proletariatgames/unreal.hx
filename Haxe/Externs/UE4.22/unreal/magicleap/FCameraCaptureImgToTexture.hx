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
  Delegate used to pass the captured image back to the initiating blueprint.
  @note The captured texture will remain in memory for the lifetime of the calling application (if the task succeeds).
  @param bSuccess True if the task succeeded, false otherwise.
  @param CaptureTexture A UTexture2D containing the captured image.
  @param bSuccess
  @param CaptureTexture
  
**/
@:glueCppIncludes("Classes/CameraCaptureComponent.h")
@:uParamName("bSuccess")
@:uParamName("CaptureTexture")
@:umodule("MagicLeap")
@:uname("UCameraCaptureComponent.FCameraCaptureImgToTexture")
typedef FCameraCaptureImgToTexture = unreal.DynamicDelegate<FCameraCaptureImgToTexture, Bool->unreal.UTexture2D->Void>;