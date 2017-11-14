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
package unreal.animgraph;


/**
  This Instance only contains one AnimationAsset, and produce poses
  Used by Preview in AnimGraph, Playing single animation in Kismet2 and etc
**/
@:umodule("AnimGraph")
@:glueCppIncludes("AnimPreviewInstance.h")
@:uextern @:uclass extern class UAnimPreviewInstance extends unreal.UAnimSingleNodeInstance {
  @:uproperty public var MontagePreviewStartSectionIdx : unreal.Int32;
  
  /**
    Shared parameters for previewing blendspace or animsequence *
  **/
  @:uproperty public var MontagePreviewType : unreal.animgraph.EMontagePreviewType;
  
}