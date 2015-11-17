package unreal;

@:glueCppIncludes("OnlineSessionInterface.h")
@:uextern @:noCopy @:noEquals @:noClass extern class IOnlineSession {
  public function CreateSession(HostingPlayerNum:Int32, SessionName:FName, NewSession:Const<PRef<FOnlineSessionSettings>>) : Bool;
  public function EndSession(SessionName:FName) : Bool;
}
