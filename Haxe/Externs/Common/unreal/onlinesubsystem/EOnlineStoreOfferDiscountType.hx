package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineStoreInterfaceV2.h") @:umodule("OnlineSubsystem")
@:uname("EOnlineStoreOfferDiscountType")
@:class @:uextern @:uenum extern enum EOnlineStoreOfferDiscountType
{
	/** Offer isn't on sale*/
	NotOnSale;
	/** Offer price should be displayed as a percentage of regular price */
	Percentage;
	/** Offer price should be displayed as an amount off regular price */
	DiscountAmount;
	/** Offer price should be displayed as a new price */
	PayAmount;
}
