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
package unreal.gameplaydebugger;

@:umodule("GameplayDebugger")
@:glueCppIncludes("GameplayDebuggerCategoryReplicator.h")
@:uextern extern class AGameplayDebuggerCategoryReplicator extends unreal.AActor {
  
  /**
    rendering component needs to attached to some actor, and this is as good as any
  **/
  private var RenderingComp : unreal.gameplaydebugger.UGameplayDebuggerRenderingComponent;
  private var DebugActor : unreal.gameplaydebugger.FGameplayDebuggerDebugActor;
  private var ReplicatedData : unreal.gameplaydebugger.FGameplayDebuggerNetPack;
  private var OwnerPC : unreal.APlayerController;
  private function ServerSetEnabled(bEnable : Bool) : Void;
  private function ServerSetDebugActor(Actor : unreal.AActor) : Void;
  private function ServerSetCategoryEnabled(CategoryId : unreal.Int32, bEnable : Bool) : Void;
  
  /**
    helper function for replicating input for category handlers
  **/
  private function ServerSendCategoryInputEvent(CategoryId : unreal.Int32, HandlerId : unreal.Int32) : Void;
  
  /**
    helper function for replicating input for extension handlers
  **/
  private function ServerSendExtensionInputEvent(ExtensionId : unreal.Int32, HandlerId : unreal.Int32) : Void;
  
}