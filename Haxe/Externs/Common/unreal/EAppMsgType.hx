package unreal;

@:glueCppIncludes("GenericPlatform/GenericPlatformMisc.h")
@:uname("EAppMsgType.Type")
@:uextern extern enum EAppMsgType {
  Ok;
  YesNo;
  OkCancel;
  YesNoCancel;
  CancelRetryContinue;
  YesNoYesAllNoAll;
  YesNoYesAllNoAllCancel;
  YesNoYesAll;
}

