package unreal;

extern class APlayerState_Extra {
  public function CopyProperties(playerState:APlayerState) : Void;

  /**
    Called by seamless travel when initializing a player on the other side - copy properties to the new PlayerState that should persist
   **/
  public function SeamlessTravelTo(NewPlayerState:APlayerState) : Void;
  /**
    session that the player needs to join/remove from as it is created/leaves
  **/
  public var SessionName : unreal.FName;
  
}
