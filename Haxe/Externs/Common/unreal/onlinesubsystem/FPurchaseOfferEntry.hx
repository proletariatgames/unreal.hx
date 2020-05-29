package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
@:uname("FPurchaseCheckoutRequest.FPurchaseOfferEntry")
@:noCopy
@:uextern extern class FPurchaseOfferEntry
{

	/*
	@:uname('.ctor') public static function create(
		OfferNamespace:Const<PRef<FString>>, OfferId:Const<PRef<FString>>, Quantity:Int32, bInIsConsumable:Bool
	):FPurchaseOfferEntry;
	//*/

	/** Namespace in which the offer resides */
	public var OfferNamespace:FString;

	/** Platform specific offer id (defined on backend) */
	public var OfferId:FString;

	/** Number of offers of this type to purchase */
	public var Quantity:Int32;

}
