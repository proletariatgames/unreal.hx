package unreal.onlinesubsystem;

import unreal.*;

/**
 * Offer entry for display from online store
 */
@:glueCppIncludes("OnlineStoreInterfaceV2.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class FOnlineStoreOffer
{

  @:uname(".ctor") static function create():FOnlineStoreOffer;

	/** Unique offer identifier */
	public var OfferId:FString;

	/** Title for display */
	public var Title:FText;
	/** Short description for display */
	public var Description:FText;
	/** Full description for display */
	public var LongDescription:FText;

	/** Date the offer was released */
	public var ReleaseDate:FDateTime;
	/** Date this information is no longer valid (maybe due to sale ending, etc) */
	public var ExpirationDate:FDateTime;
	/** Type of discount currently running on this offer (if any) */
	public var DiscountType:EOnlineStoreOfferDiscountType;

	/** Final-Price (Post-Sales/Discounts) in numeric form for comparison/sorting */
	public var NumericPrice:Int32;

	/** @return FText suitable for localized display */
	public function GetDisplayRegularPrice():FText;

	/** @return FText suitable for localized display */
	public function GetDisplayPrice():FText;

	/** @return True if offer can be purchased */
	public function IsPurchaseable():Bool;

}
