package unreal;

import unreal.*;

@:glueCppIncludes("Engine.h")
@:uextern extern class APlayerState extends AInfo {

  public var PlayerName:FString;

	public function CopyProperties(playerState:APlayerState) : Void;

	/** called by seamless travel when initializing a player on the other side - copy properties to the new PlayerState that should persist */
	public function SeamlessTravelTo(NewPlayerState:APlayerState) : Void;
}
