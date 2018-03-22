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
package unreal.oculushmd;

/**
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("OculusHMD")
@:glueCppIncludes("OculusBoundaryComponent.h")
@:uextern @:uclass extern class UOculusBoundaryComponent extends unreal.UActorComponent {
  
  /**
    For outer boundary only. Devs can bind delegates via something like: BoundaryComponent->OnOuterBoundaryReturned.AddDynamic(this, &UCameraActor::ResumeGameForBoundarySystem)
  **/
  @:uproperty public var OnOuterBoundaryReturned : unreal.oculushmd.FOculusOuterBoundaryReturnedEvent;
  
  /**
    For outer boundary only. Devs can bind delegates via something like: BoundaryComponent->OnOuterBoundaryTriggered.AddDynamic(this, &UCameraActor::PauseGameForBoundarySystem) where
    PauseGameForBoundarySystem() takes a TArray<FBoundaryTestResult> parameter.
  **/
  @:uproperty public var OnOuterBoundaryTriggered : unreal.oculushmd.FOculusOuterBoundaryTriggeredEvent;
  
}