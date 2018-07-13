package unreal;

@:glueCppIncludes("Misc/App.h")
@:uextern extern class FApp {
  /**
  * Sets the Unfocused Volume Multiplier
  */
  public static function SetUnfocusedVolumeMultiplier(InVolumeMultiplier:Float32) : Void;

  public static function IsUnattended():Bool;

  /**
    Gets the name of the currently running game.

    @return The game name
   **/
  public static function GetGameName():TCharStar;

  public static function CanEverRender():Bool;
}
