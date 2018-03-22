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

@:umodule("AIModule")
@:glueCppIncludes("EnvironmentQuery/Generators/EnvQueryGenerator_Cone.h")
@:uextern @:uclass extern class UEnvQueryGenerator_Cone extends unreal.aimodule.UEnvQueryGenerator_ProjectedPoints {
  
  /**
    The actor (or actors) that will generate a cone in their facing direction
  **/
  @:uproperty private var CenterActor : unreal.TSubclassOf<unreal.aimodule.UEnvQueryContext>;
  
  /**
    Generation distance
  **/
  @:uproperty private var Range : unreal.aimodule.FAIDataProviderFloatValue;
  
  /**
    The step of the angle increase. Angle step must be >=1
    Smaller values generate less items
  **/
  @:uproperty private var AngleStep : unreal.aimodule.FAIDataProviderFloatValue;
  
  /**
    Maximum degrees of the generated cone
  **/
  @:uproperty private var ConeDegrees : unreal.aimodule.FAIDataProviderFloatValue;
  
  /**
    Distance between each point of the same angle
  **/
  @:uproperty private var AlignedPointsDistance : unreal.aimodule.FAIDataProviderFloatValue;
  
}