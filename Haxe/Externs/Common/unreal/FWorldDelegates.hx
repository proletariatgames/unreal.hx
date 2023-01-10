package unreal;

@:glueCppIncludes('Engine/World.h')
@:uname('FWorldDelegates.FOnLevelChanged')
typedef FOnLevelChanged = MulticastDelegate<FOnLevelChanged, ULevel->UWorld->Void>;

@:glueCppIncludes('Engine/World.h')
@:uextern extern class FWorldDelegates
{
	public static var LevelAddedToWorld:FOnLevelChanged;
	public static var LevelRemovedFromWorld:FOnLevelChanged;
}
