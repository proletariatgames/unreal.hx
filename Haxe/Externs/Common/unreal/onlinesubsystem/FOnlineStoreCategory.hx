package unreal.onlinesubsystem;

import unreal.*;

/**
 * Filter for querying a subset of offers from the online store
 */
@:glueCppIncludes("OnlineStoreInterfaceV2.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class FOnlineStoreCategory
{

	/** Unique identifier for this category */
	public var Id:FString;

	/** Description for display */
	public var Description:FText;

	/** List of optional sub categories */
	public var SubCategories:TArray<FOnlineStoreCategory>;

}
