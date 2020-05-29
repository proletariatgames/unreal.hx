package unreal.onlinesubsystem;

import unreal.*;

@:glueCppIncludes("OnlineStoreInterfaceV2.h") @:umodule("OnlineSubsystem")
typedef FOnQueryOnlineStoreOffersComplete = Delegate<FOnQueryOnlineStoreOffersComplete,
	(bWasSuccessful:Bool, OfferIds:Const<PRef<TArray<FString>>>, Error:Const<PRef<FString>>)->Void
>;

@:glueCppIncludes("OnlineStoreInterfaceV2.h") @:umodule("OnlineSubsystem")
@:noCopy
@:uextern extern class IOnlineStoreV2
{

	/**
	* Query for available store offers using a filter. Delegate callback is guaranteed.
	*
	* @param UserId user initiating the request
	* @param Filter only return offers matching the filter
	* @param Delegate completion callback
	*/
	public function QueryOffersByFilter(
		UserId:Const<PRef<FUniqueNetId>>,
		Filter:Const<PRef<FOnlineStoreFilter>>,
		Delegate:Const<PRef<FOnQueryOnlineStoreOffersComplete>>
	):Void;

	/**
	 * Get currently cached store offers
	 * @param Offers [out] list of offers previously queried
	 */
	public function GetOffers(Offers:PRef<TArray<TSharedRef<FOnlineStoreOffer>>>):Void;

	/**
	 * Get currently cached store offer entry
	 * @param OfferId id of offer to find
	 * @return offer if found or invalid shared ptr
	 */
	public function GetOffer(OfferId:Const<PRef<FString>>):TSharedPtr<FOnlineStoreOffer>;

}
