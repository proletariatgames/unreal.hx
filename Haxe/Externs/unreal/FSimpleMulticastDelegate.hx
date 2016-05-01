package unreal;

@:glueCppIncludes('Delegates/Delegate.h')
typedef FSimpleMulticastDelegate = MulticastDelegate<'FSimpleMulticastDelegate', Void->Void>;
