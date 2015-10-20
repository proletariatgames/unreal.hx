package unreal;

import unreal.Scalability;

@:glueCppIncludes("GameFramework/GameUserSettings.h")
@:uextern extern class UGameUserSettings extends UObject {

	/** Applies all current user settings to the game and saves to permanent storage (e.g. file), optionally checking for command line overrides. */
	public function ApplySettings(bCheckForCommandLineOverrides:Bool) : Void;

	public function SetToDefaults() : Void;

	// cached for the UI, current state if stored in console variables
	public var ScalabilityQuality : Scalability.FQualityLevels;
}
