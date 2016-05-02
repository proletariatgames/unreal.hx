package unreal;

@:glueCppIncludes('Delegates/Delegate.h')
@:uname('FSimpleMulticastDelegate')
typedef FSimpleMulticastDelegate = MulticastDelegate<FSimpleMulticastDelegate, Void->Void>;
