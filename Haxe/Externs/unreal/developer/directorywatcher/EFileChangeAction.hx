package unreal.developer.directorywatcher;

@:glueCppIncludes("IDirectoryWatcher.h")
@:uname("FFileChangeData.EFileChangeAction")
@:uextern extern enum EFileChangeAction {
  FCA_Unknown;
  FCA_Added;
  FCA_Modified;
  FCA_Removed;
}
