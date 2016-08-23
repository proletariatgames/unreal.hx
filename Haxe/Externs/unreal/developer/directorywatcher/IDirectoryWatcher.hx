package unreal.developer.directorywatcher;

@:glueCppIncludes("IDirectoryWatcher.h")
@:uname("IDirectoryWatcher")
@:noEquals @:noCopy
@:uextern extern class IDirectoryWatcher {
  function RegisterDirectoryChangedCallback_Handle(directory:Const<PRef<FString>>,
      inDelegate:Const<PRef<FDirectoryChanged>>, outHandle:PRef<FDelegateHandle>, flags:FakeUInt32 /* = 0 */):Bool;
}

