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
package unreal.controlrig;

/**
  A component that hosts an animation ControlRig, manages control components and marshals data between the two
**/
@:umodule("ControlRig")
@:glueCppIncludes("ControlRigComponent.h")
@:uextern @:uclass extern class UControlRigComponent extends unreal.UActorComponent {
  
  /**
    The current root instance of our ControlRig
  **/
  @:uproperty public var ControlRig : unreal.controlrig.UControlRig;
  
  /**
    Event fired after this component's ControlRig is evaluated
  **/
  @:uproperty public var OnPostEvaluateDelegate : unreal.controlrig.FControlRigSignature;
  
  /**
    Event fired before this component's ControlRig is evaluated
  **/
  @:uproperty public var OnPreEvaluateDelegate : unreal.controlrig.FControlRigSignature;
  
  /**
    Event fired before this component's ControlRig is evaluated
  **/
  @:uproperty public var OnPostInitializeDelegate : unreal.controlrig.FControlRigSignature;
  
  /**
    Event fired before this component's ControlRig is initialized
  **/
  @:uproperty public var OnPreInitializeDelegate : unreal.controlrig.FControlRigSignature;
  
  /**
    Get the ControlRig hosted by this component
  **/
  @:ufunction(BlueprintCallable) @:thisConst @:final public function BP_GetControlRig() : unreal.controlrig.UControlRig;
  @:ufunction(BlueprintNativeEvent) public function OnPreInitialize() : Void;
  @:ufunction(BlueprintNativeEvent) public function OnPostInitialize() : Void;
  @:ufunction(BlueprintNativeEvent) public function OnPreEvaluate() : Void;
  @:ufunction(BlueprintNativeEvent) public function OnPostEvaluate() : Void;
  
}
