package unreal;

@:glueCppIncludes("OnlineSessionSettings.h")
@:uextern extern class FOnlineSearchResult {
 	/** All advertised session information */
	public var Session:FOnlineSession;
	/** Ping to the search result, MAX_QUERY_PING is unreachable */
	public var PingInMs:Int32;

	/**
	 *	@return true if the search result is valid, false otherwise
	 */
  @:thisCont
	public function IsValid() : Void;

	/**
	 * Check if the session info is valid, for cases where we don't need the OwningUserId
	 * @return true if the session info is valid, false otherwise
	 */
  @:thisConst
	public function IsSessionInfoValid() : Void;

	/** @return the session id for a given session search result */
	@:thisConst
  public function GetSessionIdStr() : FString;
}
