package unreal.developer.directorywatcher;

@:uname("IDirectoryWatcher.FDirectoryChanged")
typedef FDirectoryChanged = Delegate< FDirectoryChanged, Const<PRef<TArray<FFileChangeData>>>->Void >;
