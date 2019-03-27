package unreal.onlinesubsystem;

import unreal.*;

/**
 * Delegate called when a player is talking either remotely or locally
 * Called once for each active talker each frame
 *
 * @param TalkerId the player whose talking state has changed
 * @param bIsTalking if true, player is now talking, otherwise they have now stopped
 */
@:glueCppIncludes("VoiceInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("TalkerId") @:uParamName("bIsTalking")
typedef FOnPlayerTalkingStateChanged = unreal.MulticastDelegate<FOnPlayerTalkingStateChanged, TSharedRef<Const<FUniqueNetId>>->Bool->Void>;

@:glueCppIncludes("VoiceInterface.h") @:umodule("OnlineSubsystem")
@:uParamName("TalkerId") @:uParamName("bIsTalking")
typedef FOnPlayerTalkingStateChangedDelegate = unreal.Delegate<FOnPlayerTalkingStateChangedDelegate, TSharedRef<Const<FUniqueNetId>>->Bool->Void>;

@:glueCppIncludes("VoiceInterface.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class IOnlineVoice {

	/**
	 * OnPlayerTalkingStateChanged helpers
	 **/
	public function AddOnPlayerTalkingStateChangedDelegate_Handle(Delegate:Const<PRef<FOnPlayerTalkingStateChangedDelegate>>) : FDelegateHandle;
	public function ClearOnPlayerTalkingStateChangedDelegate_Handle(Handle:PRef<FDelegateHandle>) : Void;
}
