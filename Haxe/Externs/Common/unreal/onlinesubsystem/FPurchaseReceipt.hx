package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
@:uname("FPurchaseReceipt.FLineItemInfo")
@:noCopy
@:uextern extern class FLineItemInfo
{

	@:uname('.ctor') public static function create():FLineItemInfo;

	/** The platform identifier of this purchase type */
	public var ItemName:FString;

	/** unique identifier representing this purchased item (the specific instance owned by this account) */
	public var UniqueId:FString;

	/** platform-specific opaque validation info (required to verify UniqueId belongs to this account) */
	public var ValidationInfo:FString;

	public function IsRedeemable():Bool;

}

/**
 * Single purchased offer offer
 */
@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
@:uname("FPurchaseReceipt.FReceiptOfferEntry")
@:noCopy
@:uextern extern class FReceiptOfferEntry
{

	public var Namespace:FString;

	public var OfferId:FString;

	public var Quantity:Int32;

	/** Information about the individual items purchased */
	public var LineItems:TArray<FLineItemInfo>;

}

@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class FPurchaseReceipt
{

	/** Unique Id for this transaction/order */
	public var TransactionId:FString;

	/** Current state of the purchase */
	public var TransactionState:EPurchaseTransactionState;

	/** List of offers that were purchased */
	public var ReceiptOffers:TArray<FReceiptOfferEntry>;

}
