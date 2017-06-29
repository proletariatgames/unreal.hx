package unreal;

@:glueCppIncludes("GenericPlatform/GenericPlatformMisc.h")
@:uname("EAppReturnType.Type")
@:uextern extern enum EAppReturnType {
  No;
  Yes;
  YesAll;
  NoAll;
  Cancel;
  Ok;
  Retry;
  Continue;
}
