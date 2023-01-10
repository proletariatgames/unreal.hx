package unreal;

@:glueCppIncludes("Misc/WorldCompositionUtility.h")
@:uextern @:ustruct extern class FWorldTileInfo
{
	/** Tile position in the world relative to parent */
	public var Position:FIntVector;
	/** Absolute tile position in the world. Calculated in runtime */
	public var AbsolutePosition:FIntVector;
	/** Tile bounding box  */
	public var Bounds:FBox;
	/** Tile assigned layer  */
	public var Layer:FWorldTileLayer;
	/** Whether to hide sub-level tile in tile view*/
	public var bHideInTileView:Bool;
	/** Parent tile package name */
	public var ParentTilePackageName:FString;
	/** LOD information */
	public var LODList:TArray<FWorldTileLODInfo>;
	/** Sorting order */
	public var ZOrder:Int32;
}
