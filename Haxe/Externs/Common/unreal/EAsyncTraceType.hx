package unreal;

/** Enum to indicate type of test to perfom */
@:glueCppIncludes("WorldCollision.h")
@:uname("EAsyncTraceType")
@:class @:uextern extern enum EAsyncTraceType {
	/** Return whether the trace succeeds or fails (using bBlockingHit flag on FHitResult), but gives no info about what you hit or where. Good for fast occlusion tests. */
	Test;
	/** Returns a single blocking hit */
	Single;
	/** Returns a single blocking hit, plus any overlapping hits up to that point */
	Multi;
}

