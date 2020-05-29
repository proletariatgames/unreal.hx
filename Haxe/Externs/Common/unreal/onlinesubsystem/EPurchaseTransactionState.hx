package unreal.onlinesubsystem;

import unreal.*;

/**
 * State of a purchase transaction
 */
@:glueCppIncludes("OnlinePurchaseInterface.h") @:umodule("OnlineSubsystem")
@:uname("EPurchaseTransactionState")
@:class @:uextern @:uenum extern enum EPurchaseTransactionState
{
	/** processing has not started on the purchase */
	NotStarted;
	/** currently processing the purchase */
	Processing;
	/** purchase completed successfully */
	Purchased;
	/** purchase completed but failed */
	Failed;
	/** purchase has been deferred (neither failed nor completed) */
	Deferred;
	/** purchase canceled by user */
	Canceled;
	/** prior purchase that has been restored */
	Restored;
	/** purchase failed as not allowed */
	NotAllowed;
	/** purchase failed as invalid */
	Invalid;
}
