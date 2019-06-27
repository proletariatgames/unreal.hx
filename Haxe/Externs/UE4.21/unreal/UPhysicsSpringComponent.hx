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

/**
  Note: this component is still work in progress. Uses raycast springs for simple vehicle forces
     Used with objects that have physics to create a spring down the X direction
     ie. point X in the direction you want generate spring.
**/
@:glueCppIncludes("PhysicsEngine/PhysicsSpringComponent.h")
@:uextern @:uclass extern class UPhysicsSpringComponent extends unreal.USceneComponent {
  
  /**
    The current compression of the spring. A spring at rest will have SpringCompression 0.
  **/
  @:uproperty public var SpringCompression : unreal.Float32;
  
  /**
    If true, the spring will ignore all components in its own actor
  **/
  @:uproperty public var bIgnoreSelf : Bool;
  
  /**
    Strength of thrust force applied to the base object.
  **/
  @:uproperty public var SpringChannel : unreal.ECollisionChannel;
  
  /**
    Determines the radius of the spring.
  **/
  @:uproperty public var SpringRadius : unreal.Float32;
  
  /**
    Determines how long the spring will be along the X-axis at rest. The spring will apply 0 force on a body when it's at rest.
  **/
  @:uproperty public var SpringLengthAtRest : unreal.Float32;
  
  /**
    Specifies how quickly the spring can absorb energy of a body. The higher the damping the less oscillation
  **/
  @:uproperty public var SpringDamping : unreal.Float32;
  
  /**
    Specifies how much strength the spring has. The higher the SpringStiffness the more force the spring can push on a body with.
  **/
  @:uproperty public var SpringStiffness : unreal.Float32;
  
  /**
    Returns the spring compression as a normalized scalar along spring direction.
    0 implies spring is at rest
    1 implies fully compressed
  **/
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetNormalizedCompressionScalar() : unreal.Float32;
  
  /**
    Returns the spring resting point in world space.
  **/
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetSpringRestingPoint() : unreal.FVector;
  
  /**
    Returns the spring current end point in world space.
  **/
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetSpringCurrentEndPoint() : unreal.FVector;
  
  /**
    Returns the spring direction from start to resting point
  **/
  @:ufunction(BlueprintCallable) @:thisConst @:final public function GetSpringDirection() : unreal.FVector;
  
}