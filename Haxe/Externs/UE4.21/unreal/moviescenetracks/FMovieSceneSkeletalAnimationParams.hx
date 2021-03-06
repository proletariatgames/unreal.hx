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
package unreal.moviescenetracks;

@:umodule("MovieSceneTracks")
@:glueCppIncludes("Public/Sections/MovieSceneSkeletalAnimationSection.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FMovieSceneSkeletalAnimationParams {
  
  /**
    If on will skip sending animation notifies
  **/
  @:uproperty public var bSkipAnimNotifiers : Bool;
  
  /**
    The weight curve for this animation section
  **/
  @:uproperty public var Weight : unreal.moviescene.FMovieSceneFloatChannel;
  
  /**
    The slot name to use for the animation
  **/
  @:uproperty public var SlotName : unreal.FName;
  
  /**
    Reverse the playback of the animation clip
  **/
  @:uproperty public var bReverse : Bool;
  
  /**
    The playback rate of the animation clip
  **/
  @:uproperty public var PlayRate : unreal.Float32;
  
  /**
    The offset into the end of the animation clip
  **/
  @:uproperty public var EndOffset : unreal.Float32;
  
  /**
    The offset into the beginning of the animation clip
  **/
  @:uproperty public var StartOffset : unreal.Float32;
  
  /**
    The animation this section plays
  **/
  @:uproperty public var Animation : unreal.UAnimSequenceBase;
  
}
