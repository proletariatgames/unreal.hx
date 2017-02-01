package unreal;

@:glueCppIncludes("PhysicsPublic.h")
@:noCopy @:noEquals @:uextern
extern class FPhysScene {
  /** Indicates whether the scene is using substepping */
  public var bSubstepping:Bool;
}