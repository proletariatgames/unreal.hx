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
package unreal.gameplayabilities;

/**
  An instantiated Actor that acts as a handler of a GameplayCue. Since they are instantiated, they can maintain state and tick/update every frame if necessary.
**/
@:umodule("GameplayAbilities")
@:glueCppIncludes("GameplayCueNotify_Actor.h")
@:uextern @:uclass extern class AGameplayCueNotify_Actor extends unreal.AActor {
  @:ufunction public function OnOwnerDestroyed(DestroyedActor : unreal.AActor) : Void;
  
  /**
    Ends the gameplay cue: either destroying it or recycling it. You must call this manually only if you do not use bAutoDestroyOnRemove/AutoDestroyDelay
  **/
  @:ufunction(BlueprintCallable) public function K2_EndGameplayCue() : Void;
  
  /**
    How many instances of the gameplay cue to preallocate
  **/
  @:uproperty public var NumPreallocatedInstances : unreal.Int32;
  
  /**
    Does this cue trigger its WhileActive event if it's already been triggered?
    This can occur when the associated tag is triggered by multiple sources and there is no unique instancing.
  **/
  @:uproperty public var bAllowMultipleWhileActiveEvents : Bool;
  
  /**
    Does this cue trigger its OnActive event if it's already been triggered?
    This can occur when the associated tag is triggered by multiple sources and there is no unique instancing.
  **/
  @:uproperty public var bAllowMultipleOnActiveEvents : Bool;
  
  /**
    Does this cue get a new instance for each source object? For example if two source objects apply a GC to the same source, do we create two of these GameplayCue Notify actors or just one?
    If the notify is simply playing FX or sounds on the source, it should not need unique instances. If this Notify is attaching a beam from the source object to the target, it does need a unique instance per instigator.
  **/
  @:uproperty public var bUniqueInstancePerSourceObject : Bool;
  
  /**
    Does this cue get a new instance for each instigator? For example if two instigators apply a GC to the same source, do we create two of these GameplayCue Notify actors or just one?
    If the notify is simply playing FX or sounds on the source, it should not need unique instances. If this Notify is attaching a beam from the instigator to the target, it does need a unique instance per instigator.
  **/
  @:uproperty public var bUniqueInstancePerInstigator : Bool;
  
  /**
    Does this Cue override other cues, or is it called in addition to them? E.g., If this is Damage.Physical.Slash, we wont call Damage.Physical afer we run this cue.
  **/
  @:uproperty public var IsOverride : Bool;
  
  /**
    If true, attach this GameplayCue Actor to the target actor while it is active. Attaching is slightly more expensive than not attaching, so only enable when you need to.
  **/
  @:uproperty public var bAutoAttachToOwner : Bool;
  
  /**
    Mirrors GameplayCueTag in order to be asset registry searchable
  **/
  @:uproperty public var GameplayCueName : unreal.FName;
  @:uproperty public var ReferenceHelper : unreal.gameplaytags.FGameplayTagReferenceHelper;
  @:uproperty public var GameplayCueTag : unreal.gameplaytags.FGameplayTag;
  
  /**
    Warn if we have a latent action (delay, etc) running when we cleanup this gameplay cue (we will kill the latent action either way)
  **/
  @:uproperty public var WarnIfLatentActionIsStillRunning : Bool;
  
  /**
    Warn if we have a timeline running when we cleanup this gameplay cue (we will kill the timeline either way)
  **/
  @:uproperty public var WarnIfTimelineIsStillRunning : Bool;
  
  /**
    If bAutoDestroyOnRemove is true, the actor will stay alive for this many seconds before being auto destroyed.
  **/
  @:uproperty public var AutoDestroyDelay : unreal.Float32;
  
  /**
    We will auto destroy (recycle) this GameplayCueActor when the OnRemove event fires (after OnRemove is called).
  **/
  @:uproperty public var bAutoDestroyOnRemove : Bool;
  
  /**
    Generic Event Graph event that will get called for every event type
  **/
  @:ufunction(BlueprintImplementableEvent) public function K2_HandleGameplayCue(MyTarget : unreal.AActor, EventType : unreal.gameplayabilities.EGameplayCueEvent, Parameters : unreal.Const<unreal.PRef<unreal.gameplayabilities.FGameplayCueParameters>>) : Void;
  @:ufunction(BlueprintNativeEvent) public function OnExecute(MyTarget : unreal.AActor, Parameters : unreal.Const<unreal.PRef<unreal.gameplayabilities.FGameplayCueParameters>>) : Bool;
  @:ufunction(BlueprintNativeEvent) public function OnActive(MyTarget : unreal.AActor, Parameters : unreal.Const<unreal.PRef<unreal.gameplayabilities.FGameplayCueParameters>>) : Bool;
  @:ufunction(BlueprintNativeEvent) public function WhileActive(MyTarget : unreal.AActor, Parameters : unreal.Const<unreal.PRef<unreal.gameplayabilities.FGameplayCueParameters>>) : Bool;
  @:ufunction(BlueprintNativeEvent) public function OnRemove(MyTarget : unreal.AActor, Parameters : unreal.Const<unreal.PRef<unreal.gameplayabilities.FGameplayCueParameters>>) : Bool;
  
}
