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
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("AnimGraph")
@:glueCppIncludes("AnimationGraphSchema.h")
@:uextern @:uclass extern class UAnimationGraphSchema extends unreal.blueprintgraph.UEdGraphSchema_K2 {
  @:uproperty public var DefaultEvaluationHandlerName : unreal.FName;
  @:uproperty public var NAME_OnEvaluate : unreal.FName;
  @:uproperty public var NAME_CustomizeProperty : unreal.FName;
  @:uproperty public var NAME_AlwaysAsPin : unreal.FName;
  @:uproperty public var NAME_PinShownByDefault : unreal.FName;
  @:uproperty public var NAME_PinHiddenByDefault : unreal.FName;
  
  /**
    PC_Object+PSC_Sequence
  **/
  @:uproperty public var NAME_NeverAsPin : unreal.FName;
  
  /**
    Common PinNames
  **/
  @:uproperty public var PN_SequenceName : unreal.FString;
  
}