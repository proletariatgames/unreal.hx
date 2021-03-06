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
package unreal;

@:glueCppIncludes("Classes/Animation/AnimStateMachineTypes.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FBakedStateExitTransition {
  @:uproperty public var PoseEvaluatorLinks : unreal.TArray<unreal.Int32>;
  
  /**
    Automatic Transition Rule based on animation remaining time.
  **/
  @:uproperty public var bAutomaticRemainingTimeRule : Bool;
  
  /**
    What the transition rule node needs to return to take this transition (for bidirectional transitions)
  **/
  @:uproperty public var bDesiredTransitionReturnValue : Bool;
  
  /**
    The index into the machine table of transitions
  **/
  @:uproperty public var TransitionIndex : unreal.Int32;
  
  /**
    The blend graph result node index
  **/
  @:uproperty public var CustomResultNodeIndex : unreal.Int32;
  
  /**
    The node property index for this rule
  **/
  @:uproperty public var CanTakeDelegateIndex : unreal.Int32;
  
}
