package unreal;

@:glueCppIncludes("TimerManager.h")
@:uname('FTimerDynamicDelegate')
typedef FTimerDynamicDelegate = DynamicDelegate<FTimerDelegate, Void->Void>;

