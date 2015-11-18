package unreal;

@:glueCppIncludes("SlateApplication.h")
@:uextern extern class FSlateApplication
{
  public static function Get() : PRef<FSlateApplication>;

  public function GetInitialDisplayMetrics(MetricsOut:PRef<FDisplayMetrics>) : Void;
  public function SetAllUserFocusToGameViewport() : Void;
}
