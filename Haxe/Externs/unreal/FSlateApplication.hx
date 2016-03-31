package unreal;

@:glueCppIncludes("SlateApplication.h")
@:uextern @:noCopy @:noEquals extern class FSlateApplication
{
  public static function Get() : PRef<FSlateApplication>;

  public function GetInitialDisplayMetrics(MetricsOut:PRef<FDisplayMetrics>) : Void;
  public function SetAllUserFocusToGameViewport() : Void;
}
