package unreal;

@:glueCppIncludes("Misc/WorldCompositionUtility.h")
@:uextern @:ustruct extern class FWorldTileLODInfo
{
	/**  Relative to LOD0 streaming distance, absolute distance = LOD0 + StreamingDistanceDelta */
	public var RelativeStreamingDistance:Int32;
}
