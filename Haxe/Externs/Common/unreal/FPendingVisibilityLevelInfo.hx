package unreal;

// OGLES: Prioritized streaming system (added in our engine fork)
@:glueCppIncludes('Classes/Engine/World.h')
@:uextern extern class FPendingVisibilityLevelInfo
{
  public var Level:unreal.ULevel;
  public var LevelTransform:unreal.FTransform;
}
