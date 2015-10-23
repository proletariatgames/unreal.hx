package unreal;

/**
 * Expand with more types as we need them.
 * Someday auto-extern will make this automatic and there will be much rejoicing
 */
@:glueCppIncludes("Engine/EngineTypes.h")
@:uname("ENetRole")
@:uextern extern enum ENetRole {
	/** No role at all. */
	ROLE_None;
	/** Locally simulated proxy of this actor. */
	ROLE_SimulatedProxy;
	/** Locally autonomous proxy of this actor. */
	ROLE_AutonomousProxy;
	/** Authoritative control over the actor. */
	ROLE_Authority;
	ROLE_MAX;
}