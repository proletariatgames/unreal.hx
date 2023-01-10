package unreal;

@:glueCppIncludes("Engine/WorldComposition.h")
@:uextern @:ustruct extern class FWorldCompositionTile
{
	public var PackageName:unreal.FName;
	public var LODPackageNames:TArray<FName>;
	public var Info:FWorldTileInfo;
	public var StreamingLevelStateChangeTime:Float;
}
