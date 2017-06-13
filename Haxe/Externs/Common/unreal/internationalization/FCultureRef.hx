package unreal.internationalization;

@:global
@:nocopy @:noEquals
@:glueCppIncludes("Internationalization/CulturePointer.h")
@:uname("FCultureRef")
typedef FCultureRef = TThreadSafeSharedRef<FCulture>;