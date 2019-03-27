package unreal;

extern class AHUD_Extra {
	/** The Main Draw loop for the hud.  Gets called before any messaging.  Should be subclassed */
  public function DrawHUD() : Void;
}
