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
  Run Environment Query System Query task node.
  Runs the specified environment query when executed.
**/
@:umodule("AIModule")
@:glueCppIncludes("BehaviorTree/Tasks/BTTask_RunEQSQuery.h")
@:uextern @:uclass extern class UBTTask_RunEQSQuery extends unreal.aimodule.UBTTask_BlackboardBase {
  @:uproperty public var EQSRequest : unreal.aimodule.FEQSParametrizedQueryExecutionRequest;
  @:uproperty public var bUseBBKey : Bool;
  
  /**
    blackboard key storing an EQS query template
  **/
  @:uproperty public var EQSQueryBlackboardKey : unreal.aimodule.FBlackboardKeySelector;
  
  /**
    determines which item will be stored (All = only first matching)
  **/
  @:uproperty public var RunMode : unreal.aimodule.EEnvQueryRunMode;
  @:uproperty public var QueryConfig : unreal.TArray<unreal.aimodule.FAIDynamicParam>;
  
  /**
    optional parameters for query
  **/
  @:uproperty public var QueryParams : unreal.TArray<unreal.aimodule.FEnvNamedValue>;
  
  /**
    query to run
  **/
  @:uproperty public var QueryTemplate : unreal.aimodule.UEnvQuery;
  
}
