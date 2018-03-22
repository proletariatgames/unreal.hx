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

/**
  Implements a section in sub-sequence tracks.
**/
@:umodule("MovieSceneTracks")
@:glueCppIncludes("Sections/MovieSceneSubSection.h")
@:uextern @:uclass extern class UMovieSceneSubSection extends unreal.moviescene.UMovieSceneSection {
  
  /**
    Target path of sequence to record to
  **/
  @:uproperty private var TargetPathToRecordTo : unreal.FDirectoryPath;
  
  /**
    Target name of sequence to try to record to (will record automatically to another if this already exists)
  **/
  @:uproperty private var TargetSequenceName : unreal.FString;
  
  /**
    Movie scene being played by this section.
    
    @todo Sequencer: Should this be lazy loaded?
  **/
  @:uproperty private var SubSequence : unreal.moviescene.UMovieSceneSequence;
  @:uproperty public var Parameters : unreal.moviescene.FMovieSceneSectionParameters;
  
}