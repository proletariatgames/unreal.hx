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
package unreal.animationsharing;

@:umodule("AnimationSharing")
@:glueCppIncludes("AnimationSharingSetup.h")
@:uextern @:uclass extern class UAnimationSharingSetup extends unreal.UObject {
  @:uproperty public var ScalabilitySettings : unreal.animationsharing.FAnimationSharingScalability;
  @:uproperty public var SkeletonSetups : unreal.TArray<unreal.animationsharing.FPerSkeletonAnimationSharingSetup>;
  
}