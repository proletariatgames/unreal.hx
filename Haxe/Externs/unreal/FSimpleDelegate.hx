package unreal;

@:glueCppIncludes('Delegates/Delegate.h')
@:uname('FSimpleDelegate')
typedef FSimpleDelegate = Delegate<FSimpleDelegate, Void->Void>;
