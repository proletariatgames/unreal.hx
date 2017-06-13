package unreal.webbrowserwidget;

extern class UWebBrowser_Extra {
  /**
   * Get the current title of the web page
   */
  @:thisConst
  public function GetTitleText():FText;

  public var OnUrlChanged (get,never):FOnUrlChanged;
  public var OnLoadUrl (get,never):FOnLoadUrlEvent;
}