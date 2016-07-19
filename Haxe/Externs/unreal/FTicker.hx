package unreal;

@:glueCppIncludes('Containers/Ticker.h')
@:uextern extern class FTicker {

  /** Singleton used for the ticker in Core / Launch. If you add a new ticker for a different subsystem, do not put that singleton here! **/
  public static function GetCoreTicker():PRef<FTicker>;

  /**
   * Add a new ticker with a given delay / interval
   *
   * @param InDelegate Delegate to fire after the delay
   * @param InDelay Delay until next fire; 0 means "next frame"
   */
  function AddTicker(InDelegate:PRef<FTickerDelegate>, delay:Float32 /* = 0 */):FDelegateHandle;

  /**
   * Removes a previously added ticker delegate.
   *
   * Note: will remove ALL tickers that use this handle, as there's no way to uniquely identify which one you are trying to remove.
   *
   * @param Handle The handle of the ticker to remove.
   */
  function RemoveTicker(Handle:FDelegateHandle):Void;
}
