package unreal;

@:glueCppIncludes("Misc/WorldCompositionUtility.h")
@:uextern @:ustruct extern class FWorldTileLayer
{
	/** Human readable name for this layer */
	public var Name:FString;
	/** Distance starting from where tiles belonging to this layer will be streamed in */
	public var StreamingDistance:Int32;
	public var DistanceStreamingEnabled:Bool;
}
