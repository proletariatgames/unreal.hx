package unreal.onlinesubsystem;


@:umodule("OnlineSubsystem")
@:glueCppIncludes("OnlineSubsystemTypes.h")
@:uname("ELoginStatus.Type")
@:uextern extern enum ELoginStatus {
  NotLoggedIn;
  UsingLocalProfile;
  LoggedIn; 
}
