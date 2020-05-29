package unreal.onlinesubsystem;

import unreal.*;

/**
 * Delegate called when checkout process completes
 */
@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
typedef FOnPurchaseCheckoutComplete = Delegate<FOnPurchaseCheckoutComplete,
	(Result:Const<PRef<FOnlineError>>, Receipt:Const<PRef<TSharedRef<FPurchaseReceipt>>>)->Void
>;

@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
typedef FOnFinalizeReceiptValidationInfoComplete = Delegate<FOnFinalizeReceiptValidationInfoComplete,
	(Result:Const<PRef<FOnlineError>>, OwnershipToken:Const<PRef<FString>>)->Void
>;

@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class IOnlinePurchase
{

	/**
	* Determine if user is allowed to purchase from store
	*
	* @param UserId user initiating the request
	*
	* @return true if user can make a purchase
	*/
	public function IsAllowedToPurchase(UserId:Const<PRef<FUniqueNetId>>):Bool;

	/**
	 * Initiate the checkout process for purchasing offers via payment.
	 * Delegate will include a reference to the receipt object.
	 * This object is cached locally until the purchase flow is complete.
	 * The user should execute `FinalizeReceiptValidationInfo` to get ownership validation tokens
	 * which can then be redeemed on the game service. After the tokens have been validated
	 * the entitlements have been granted, execute `FinalizePurchase` which will dispose of the receipt.
	 *
	 * @param UserId user initiating the request
	 * @param CheckoutRequest info needed for the checkout request
	 * @param Delegate completion callback (guaranteed to be called)
	 */
	public function Checkout(
		UserId:Const<PRef<FUniqueNetId>>,
		CheckoutRequest:Const<PRef<FPurchaseCheckoutRequest>>,
		Delegate:Const<PRef<FOnPurchaseCheckoutComplete>>
	):Void;

	/**
	 * Requests an ownership token so that a game service can validate its ownership for the user
	 * by using the Offline Ownership Validation flow.
	 * https://dev.epicgames.com/docs/services/INT/Interfaces/Ecom/#ownershipverificationtokendetails
	 * Should be executed after a purchase has been made via `Checkout`.
	 * Per the above documentation, the token is only valid for 5 minutes.
	 * If validation fails due to timeout, this function can be called again to get a new token until
	 * `FinalizePurchase` is executed (which removes the receipt from the cache).
	 */
	public function FinalizeReceiptValidationInfo(
		UserId:Const<PRef<FUniqueNetId>>, ReceiptId:Const<PRef<FString>>,
		Delegate:Const<PRef<FOnFinalizeReceiptValidationInfoComplete>>
	):Void;

	/**
	 * Finalizes a purchase with the supporting platform.
	 * Acknowledges that the purchase has been properly redeemed by the application.
	 * Should be executed with the ReceiptId after `FinalizeReceiptValidationInfo`
	 * has been called and ownership tokens have been sent to the game service.
	 *
	 * @param UserId user where the purchase was made
	 * @param ReceiptId purchase id for this platform
	 */
	public function FinalizePurchase(UserId:Const<PRef<FUniqueNetId>>, ReceiptId:Const<PRef<FString>>):Void;

}
