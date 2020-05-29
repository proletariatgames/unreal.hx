package unreal.onlinesubsystem;

import unreal.*;

/**
 * Filter for querying a subset of offers from the online store
 */
@:glueCppIncludes("OnlineStoreInterfaceV2.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class FOnlineStoreFilter
{

	@:uname('.ctor') public static function create():FOnlineStoreFilter;

	/** Keyword strings to match when filtering items/offers */
	public var Keywords:TArray<FString>;

	/** Category paths to match when filtering offers */
	public var IncludeCategories:TArray<FOnlineStoreCategory>;

	/** Category paths to exclude when filtering offers */
	public var ExcludeCategories:TArray<FOnlineStoreCategory>;

}
