package unreal;

@:glueCppIncludes("TimerManager.h")
@:uname('FTimerDelegate')
typedef FTimerDelegate = Delegate<FTimerDelegate, Void->Void>;

