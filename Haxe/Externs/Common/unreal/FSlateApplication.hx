package unreal;

@:glueCppIncludes("SlateApplication.h")
@:uextern @:noCopy @:noEquals extern class FSlateApplication
{
  public static function Get() : PRef<FSlateApplication>;

  public function GetInitialDisplayMetrics(MetricsOut:PRef<FDisplayMetrics>) : Void;
  public function SetAllUserFocusToGameViewport() : Void;

  public static function IsInitialized() : Bool;

  /** @return the last time a user interacted with a keyboard, mouse, touch device, or controller */
  @:thisConst
  public function GetLastUserInteractionTime() : Float;
}

