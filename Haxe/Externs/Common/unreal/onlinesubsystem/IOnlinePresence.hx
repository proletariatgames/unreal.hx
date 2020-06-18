package unreal.onlinesubsystem;

import unreal.*;


@:glueCppIncludes("OnlinePresenceInterface.h")
@:uextern @:noCopy @:noEquals @:noClass extern class IOnlinePresence {
	public function SetPresence(UserId:Const<PRef<unreal.FUniqueNetId>>, Status:Const<PRef<FOnlineUserPresenceStatus>>):Void;
}
