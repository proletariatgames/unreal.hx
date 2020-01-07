package unreal;

@:glueCppIncludes("WorldCollision.h")
@:uextern extern class FTraceDatum {
	public function new();
	public var Start:FVector;
	public var End:FVector;
	public var OutHits:TArray<FHitResult>;
	public var TraceType:EAsyncTraceType;
}
