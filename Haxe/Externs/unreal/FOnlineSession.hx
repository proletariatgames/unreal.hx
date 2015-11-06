package unreal;

@:glueCppIncludes("OnlineSessionSettings.h")
@:uname("FOnlineSession")
@:ustruct
@:uextern extern class FOnlineSession {

	/** The platform specific session information */
	public var SessionInfo : TSharedPtr<FOnlineSessionInfo>;
	/** The number of private connections that are available (read only) */
	public var NumOpenPrivateConnections : Int32;
	/** The number of publicly available connections that are available (read only) */
	public var NumOpenPublicConnections : Int32;

}