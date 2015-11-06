package unreal;

@:glueCppIncludes("Engine/EngineBaseTypes.h")
@:uname("ETravelType")
@:uenum
@:uextern extern enum ETravelType {
	/** Absolute URL. */
	TRAVEL_Absolute;
	/** Partial (carry name; reset server). */
	TRAVEL_Partial;
	/** Relative URL. */
	TRAVEL_Relative;
	TRAVEL_MAX;
}
