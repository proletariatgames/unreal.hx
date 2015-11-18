package unreal;

extern class UGameUserSettings_Extra {
  /**
    Applies all current user settings to the game and saves to permanent storage (e.g. file), optionally checking for command line overrides.
   **/
  public function ApplySettings(bCheckForCommandLineOverrides:Bool) : Void;

  public function SetToDefaults() : Void;

  public function GetFullscreenMode() : EWindowMode;
  public function GetLastConfirmedFullscreenMode() : EWindowMode;
  public function SetFullscreenMode(In:EWindowMode) : Void;

  public function GetScreenResolution() : FIntPoint;
  public function GetLastConfirmedScreenResolution() : FIntPoint;
  public function SetScreenResolution(Resolution:FIntPoint) : Void;

  /**
    Cached for the UI, current state if stored in console variables
   **/
  public var ScalabilityQuality : Scalability.FQualityLevels;
}
