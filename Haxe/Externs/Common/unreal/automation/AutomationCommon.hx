package unreal.automation;

@:glueCppIncludes("AutomationCommon.h")
@:noCopy @:noEquals
@:uextern extern class AutomationCommon {

  /**
   * If Editor, Opens map and PIES.  If Game, transitions to map and waits for load
   */
  @:global public static function AutomationOpenMap(MapName:Const<PRef<FString>>):Bool;

  public static function GetScreenshotPath(TestName:Const<PRef<FString>>, OutScreenshotName:PRef<FString>):Void;

  public static function OnEditorAutomationMapLoadDelegate():PRef<FOnEditorAutomationMapLoad>;
}

@:glueCppIncludes("AutomationCommon.h")
typedef FOnEditorAutomationMapLoad = MulticastDelegate<FOnEditorAutomationMapLoad, Const<PRef<FString>>->PPtr<FString>->Void>;
