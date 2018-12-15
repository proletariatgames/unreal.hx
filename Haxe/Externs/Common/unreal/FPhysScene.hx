package unreal;

@:glueCppIncludes("PhysicsPublic.h")
@:noCopy @:noEquals @:uextern
extern class FPhysScene {
#if (UE_VER <= 4.19)
  /** Indicates whether the scene is using substepping */
  public var bSubstepping:Bool;
#end
}