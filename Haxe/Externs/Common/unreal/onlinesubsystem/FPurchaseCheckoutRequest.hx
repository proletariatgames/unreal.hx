package unreal.onlinesubsystem;

import unreal.*;

/**
 * Info needed for checkout
 */
@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class FPurchaseCheckoutRequest
{

	@:uname('.ctor') public static function create():FPurchaseCheckoutRequest;

	/** List of offers being purchased */
	public var PurchaseOffers:TArray<FPurchaseOfferEntry>;

	/**
	 * Add a offer entry for purchase
	 *
	 * @param InNamespace namespace of offer to be purchased
	 * @param InOfferId id of offer to be purchased
	 * @param InQuantity number to purchase
	 * @param bInIsConsumable is the offer consumable or one time purchase. Defaults to true.
	 */
	public function AddPurchaseOffer(
		Namespace:Const<PRef<FString>>,
		OfferId:Const<PRef<FString>>,
		InQuantity:Int32,
		bInIsConsumable:Bool=true
	):Void;

}
