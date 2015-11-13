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
package unreal;

@:glueCppIncludes("Components/LightComponentBase.h")
@:uextern extern class ULightComponentBase extends unreal.USceneComponent {
  #if WITH_EDITORONLY_DATA
  
  /**
    Sprite scaling for dynamic light in the editor.
  **/
  public var DynamicEditorTextureScale : unreal.Float32;
  
  /**
    Sprite for dynamic light in the editor.
  **/
  public var DynamicEditorTexture : unreal.UTexture2D;
  
  /**
    Sprite scaling for static light in the editor.
  **/
  public var StaticEditorTextureScale : unreal.Float32;
  
  /**
    Sprite for static light in the editor.
  **/
  public var StaticEditorTexture : unreal.UTexture2D;
  #end // WITH_EDITORONLY_DATA
  
  /**
    Scales the indirect lighting contribution from this light.
    A value of 0 disables any GI from this light. Default is 1.
  **/
  public var IndirectLightingIntensity : unreal.Float32;
  
  /**
    The precomputed lighting for that light source is valid. It might become invalid if some properties change (e.g. position, brightness).
  **/
  public var bPrecomputedLightingIsValid : Bool;
  
  /**
    Whether the light affects translucency or not.  Disabling this can save GPU time when there are many small lights.
  **/
  public var bAffectTranslucentLighting : Bool;
  
  /**
    Whether the light should cast shadows from dynamic objects.  Also requires Cast Shadows to be set to True.
  **/
  public var CastDynamicShadows : Bool;
  
  /**
    Whether the light should cast shadows from static objects.  Also requires Cast Shadows to be set to True.
  **/
  public var CastStaticShadows : Bool;
  
  /**
    Whether the light should cast any shadows.
  **/
  public var CastShadows : Bool;
  
  /**
    Whether the light can affect the world, or whether it is disabled.
    A disabled light will not contribute to the scene in any way.  This setting cannot be changed at runtime and unbuilds lighting when changed.
    Setting this to false has the same effect as deleting the light, so it is useful for non-destructive experiments.
  **/
  public var bAffectsWorld : Bool;
  
  /**
    Filter color of the light.
    Note that this can change the light's effective intensity.
  **/
  public var LightColor : unreal.FColor;
  
  /**
    Total energy that the light emits.
    For point/spot lights with inverse squared falloff, this is in units of lumens.  1700 lumens corresponds to a 100W lightbulb.
    For other lights, this is just a brightness multiplier.
  **/
  public var Intensity : unreal.Float32;
  @:deprecated public var Brightness_DEPRECATED : unreal.Float32;
  
  /**
    GUID used to associate a light component with precomputed shadowing information across levels.
    The GUID changes whenever the light position changes.
  **/
  public var LightGuid : unreal.FGuid;
  
  /**
    Sets whether this light casts shadows
  **/
  @:final public function SetCastShadows(bNewValue : Bool) : Void;
  
  /**
    Gets the light color as a linear color
  **/
  @:thisConst @:final public function GetLightColor() : unreal.FLinearColor;
  
}
