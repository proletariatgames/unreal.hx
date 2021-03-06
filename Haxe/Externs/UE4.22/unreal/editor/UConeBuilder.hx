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
package unreal.editor;

/**
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("UnrealEd")
@:glueCppIncludes("Builders/ConeBuilder.h")
@:uextern @:uclass extern class UConeBuilder extends unreal.editor.UEditorBrushBuilder {
  
  /**
    Whether this is a hollow or solid cone
  **/
  @:uproperty public var Hollow : Bool;
  
  /**
    Whether to align the brush to a face
  **/
  @:uproperty public var AlignToSide : Bool;
  @:uproperty public var GroupName : unreal.FName;
  
  /**
    How many sides this cone should have
  **/
  @:uproperty public var Sides : unreal.Int32;
  
  /**
    Radius of inner cone (when hollow)
  **/
  @:uproperty public var InnerRadius : unreal.Float32;
  
  /**
    Radius of cone
  **/
  @:uproperty public var OuterRadius : unreal.Float32;
  
  /**
    Distance from base to the tip of inner cone (when hollow)
  **/
  @:uproperty public var CapZ : unreal.Float32;
  
  /**
    Distance from base to tip of cone
  **/
  @:uproperty public var Z : unreal.Float32;
  
}
