package unreal;

@:glueCppIncludes("Misc/App.h")
@:uextern extern class FApp {
  /**
  * Sets the Unfocused Volume Multiplier
  */
  public static function SetUnfocusedVolumeMultiplier(InVolumeMultiplier:Float32) : Void;
}
