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
package unreal.editor;


/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("UnrealEd")
@:glueCppIncludes("Factories/SoundFactory.h")
@:noClass @:uextern extern class USoundFactory extends unreal.editor.UFactory {
  
  /**
    If not empty, generated SoundCues will be placed in PackageCuePackageSuffix, but only if bAutoCreateCue is true
  **/
  public var CuePackageSuffix : unreal.FString;
  
  /**
    The volume of the created sound cue
  **/
  public var CueVolume : unreal.Float32;
  
  /**
    If enabled, the created sound cue will include a modulator node
  **/
  public var bIncludeModulatorNode : Bool;
  
  /**
    If enabled, the created sound cue will include a looping node
  **/
  public var bIncludeLoopingNode : Bool;
  
  /**
    If enabled, the created sound cue will include a attenuation node
  **/
  public var bIncludeAttenuationNode : Bool;
  
  /**
    If enabled, a sound cue will automatically be created for the sound
  **/
  public var bAutoCreateCue : Bool;
  
}