package unreal.umg;

@:umodule("WebBrowserWidget")
@:glueCppIncludes("WebBrowser.h")
@:uextern extern class UWebBrowser extends unreal.umg.UWidget {

  /**
   * Load the specified URL
   *
   * @param NewURL New URL to load
   */
  public function LoadURL(NewURL:FString):Void;

  /**
   * Load a string as data to create a web page
   *
   * @param Contents String to load
   * @param DummyURL Dummy URL for the page
   */
  // FIXME: externing LoadString causes an external in glue code.
  // Not needed for now, but adding this comment in case someone does in the
  // future and must debug it.
  // public function LoadString(Contents:FString, DummyURL:FString):Void;

  /**
   * Get the current title of the web page
   */
  @:thisConst
  public function GetTitleText():FText;

  public var OnUrlChanged (get,never):FOnUrlChangedEvent;
  public var OnLoadUrl (get,never):FOnLoadUrlEvent;
}
