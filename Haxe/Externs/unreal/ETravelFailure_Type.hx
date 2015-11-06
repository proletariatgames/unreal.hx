package unreal;

@:glueCppIncludes("Engine/EngineBaseTypes.h")
@:uname("ETravelFailure.Type")
@:uextern extern enum ETravelFailure_Type {
	/** No level found in the loaded package */
	NoLevel;
	/** LoadMap failed on travel (about to Browse to default map) */
	LoadMapFailure;
	/** Invalid URL specified */
	InvalidURL;
	/** A package is missing on the client */
	PackageMissing;
	/** A package version mismatch has occurred between client and server */
	PackageVersion;
	/** A package is missing and the client is unable to download the file */
	NoDownload;
	/** General travel failure */
	TravelFailure;
	/** Cheat commands have been used disabling travel */
	CheatCommands;
	/** Failed to create the pending net game for travel */
	PendingNetGameCreateFailure;
	/** Failed to save before travel */
	CloudSaveFailure;
	/** There was an error during a server travel to a new map */
	ServerTravelFailure;
	/** There was an error during a client travel to a new map */
	ClientTravelFailure;
}
