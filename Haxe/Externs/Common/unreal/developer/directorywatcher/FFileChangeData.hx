package unreal.developer.directorywatcher;

@:glueCppIncludes("IDirectoryWatcher.h")
@:uname("FFileChangeData")
@:uextern extern class FFileChangeData {
  var Filename:FString;
  var Action:EFileChangeAction;
}

