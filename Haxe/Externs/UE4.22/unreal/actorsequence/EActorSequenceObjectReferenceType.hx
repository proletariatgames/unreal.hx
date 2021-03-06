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
package unreal.actorsequence;

@:umodule("ActorSequence")
@:glueCppIncludes("Public/ActorSequenceObjectReference.h")
@:uname("EActorSequenceObjectReferenceType")
@:class @:uextern @:uenum extern enum EActorSequenceObjectReferenceType {
  
  /**
    The reference relates to the context actor
  **/
  ContextActor;
  
  /**
    The reference relates to an actor outside of the context actor actor
  **/
  ExternalActor;
  
  /**
    The reference relates to a component
  **/
  Component;
  
}
