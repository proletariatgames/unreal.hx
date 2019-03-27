package unreal;

@:glueCppIncludes("Engine/EngineTypes.h")
@:uname("ENetDormancy")
@:uextern extern enum ENetDormancy {
  /** This actor can never go network dormant. */
	DORM_Never;
	/** This actor can go dormant, but is not currently dormant. Game code will tell it when it go dormant. */
	DORM_Awake;
	/** This actor wants to go fully dormant for all connections. */
	DORM_DormantAll;
	/** This actor may want to go dormant for some connections, GetNetDormancy() will be called to find out which. */
	DORM_DormantPartial;
	/** This actor is initially dormant for all connection if it was placed in map. */
	DORM_Initial;
	DORN_MAX;
}
