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
package unreal.aimodule;

/**
  keep in sync with DescribeFinishMode
**/
@:umodule("AIModule")
@:glueCppIncludes("Classes/BehaviorTree/Composites/BTComposite_SimpleParallel.h")
@:uname("EBTParallelMode.Type")
@:uextern @:uenum extern enum EBTParallelMode {
  
  /**
    When main task finishes, immediately abort background tree.
    @DisplayName Immediate
  **/
  @DisplayName("Immediate")
  AbortBackground;
  
  /**
    When main task finishes, wait for background tree to finish.
    @DisplayName Delayed
  **/
  @DisplayName("Delayed")
  WaitForBackground;
  
}
