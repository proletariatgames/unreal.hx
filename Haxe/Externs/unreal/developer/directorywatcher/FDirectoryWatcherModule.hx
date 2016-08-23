package unreal.developer.directorywatcher;

@:glueCppIncludes("DirectoryWatcherModule.h")
@:uname("FDirectoryWatcherModule")
@:uextern extern class FDirectoryWatcherModule {
  function StartupModule():Void;
  function ShutdownModule():Void;
  function Get():PPtr<IDirectoryWatcher>;
}
