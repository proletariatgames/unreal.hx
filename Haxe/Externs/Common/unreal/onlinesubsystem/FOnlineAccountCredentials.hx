package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineIdentityInterface.h") @:umodule("OnlineSubsystem")
@:uextern extern class FOnlineAccountCredentials
{
	/** Type of account. Needed to identity the auth method to use (epic, internal, facebook, etc) */
	public var Type : FString;
	/** Id of the user logging in (email, display name, facebook id, etc) */
	public var Id : FString;
	/** Credentials of the user logging in (password or auth token) */
	public var Token : FString;

	// /**
	//  * Constructor
	//  */
	public function new();
	@:uname('.ctor') public static function create() : FOnlineAccountCredentials;

	@:uname('.ctor') public static function createFromValues(InType:Const<PRef<FString>>,
		InId:Const<PRef<FString>>,
		InToken:Const<PRef<FString>>) : FOnlineAccountCredentials;
}

