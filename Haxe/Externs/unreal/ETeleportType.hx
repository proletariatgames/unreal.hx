package unreal;

@:glueCppIncludes("Components/ActorComponent.h")
@:uname("ETeleportType")
@:uextern @:class extern enum ETeleportType {
	/** Do not teleport physics body. This means velocity will reflect the movement between initial and final position, and collisions along the way will occur */
	None;
	/** Teleport physics body so that velocity remains the same and no collision occurs */
	TeleportPhysics;
}
