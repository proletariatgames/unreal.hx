package unreal.internationalization;

@:global
@:nocopy @:noEquals
@:glueCppIncludes("Internationalization/CulturePointer.h")
@:uname("FCulturePtr")
typedef FCulturePtr = TThreadSafeSharedPtr<FCulture>;