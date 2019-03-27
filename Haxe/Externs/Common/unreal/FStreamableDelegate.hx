package unreal;

@:glueCppIncludes("Engine/StreamableManager.h")
@:uname('FStreamableDelegate')
typedef FStreamableDelegate = Delegate<FStreamableDelegate, Void->Void>;
