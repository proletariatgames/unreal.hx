package unreal.developer.sourcecontrol;

@:glueCppIncludes("ISourceControlState.h")
@:noCopy @:noEquals
@:uextern extern class ISourceControlState
{
	/**
	 * Get the size of the history.
	 * If an FUpdateStatus operation has been called with the ShouldUpdateHistory() set, there
	 * should be history present if the file has been committed to source control.
	 * @returns the number of items in the history
	 */
	@:thisConst function GetHistorySize() : Int32;

	/**
	 * Get an item from the history
	 * @param	HistoryIndex	the index of the history item
	 * @returns a history item or NULL if none exist
	 */
	// @:thisConst function GetHistoryItem(HistoryIndex:Int32) : TThreadSafeSharedPtr<ISourceControlRevision>;

	/**
	 * Find an item from the history with the specified revision number.
	 * @param	RevisionNumber	the revision number to look for
	 * @returns a history item or NULL if the item could not be found
	 */
	// @:thisConst function FindHistoryRevision(RevisionNumber:Int32) : TThreadSafeSharedPtr<ISourceControlRevision>;

	/**
	 * Find an item from the history with the specified revision.
	 * @param	InRevision	the revision identifier to look for
	 * @returns a history item or NULL if the item could not be found
	 */
	// @:thisConst function FindHistoryRevision(InRevision:Const<PRef<FString>>) : TThreadSafeSharedPtr<ISourceControlRevision>;

	/**
	 * Get the revision that we should use as a base when performing a three wage merge, does not refresh source control state
	 * @returns a revision identifier or NULL if none exist
	 */
	// @:thisConst function GetBaseRevForMerge() : TThreadSafeSharedPtr<ISourceControlRevision>;

	/**
	 * Get the name of the icon graphic we should use to display the state in a UI.
	 * @returns the name of the icon to display
	 */
	@:thisConst function GetIconName() : FName;

	/**
	 * Get the name of the small icon graphic we should use to display the state in a UI.
	 * @returns the name of the icon to display
	 */
	@:thisConst function GetSmallIconName() : FName;

	/**
	 * Get a text representation of the state
	 * @returns	the text to display for this state
	 */
	@:thisConst function GetDisplayName() : FText;

	/**
	 * Get a tooltip to describe this state
	 * @returns	the text to display for this states tooltip
	 */
	@:thisConst function GetDisplayTooltip() : FText;

	/**
	 * Get the local filename that this state represents
	 * @returns	the filename
	 */
	@:thisConst function GetFilename() : Const<PRef<FString>>;

	/**
	 * Get the timestamp of the last update that was made to this state.
	 * @returns	the timestamp of the last update
	 */
	@:thisConst function GetTimeStamp() : Const<PRef<FDateTime>>;

	/** Get whether this file can be checked in. */
	@:thisConst function CanCheckIn() : Bool;

	/** Get whether this file can be checked out */
	@:thisConst function CanCheckout() : Bool;

	/** Get whether this file is checked out */
	@:thisConst function IsCheckedOut() : Bool;

	/** Get whether this file is checked out by someone else in the current branch */
	@:thisConst function IsCheckedOutOther(Who:PPtr<FString> = null) : Bool;

	/** Get whether this file is checked out in a different branch, if no branch is specified defaults to FEngineVerion current branch */
	@:thisConst function IsCheckedOutInOtherBranch(@:opt("") ?CurrentBranch:Const<PRef<FString>>) : Bool;

	/** Get whether this file is modified in a different branch, if no branch is specified defaults to FEngineVerion current branch */
	@:thisConst function IsModifiedInOtherBranch(@:opt("") ?CurrentBranch:Const<PRef<FString>> ) : Bool;

	/** Get whether this file is checked out or modified in a different branch, if no branch is specified defaults to FEngineVerion current branch */
	@:thisConst function IsCheckedOutOrModifiedInOtherBranch(@:opt("") ?CurrentBranch:Const<PRef<FString>> ) : Bool;

	/** Get the other branches this file is checked out in */
	@:thisConst function GetCheckedOutBranches() : TArray<FString>;

	/** Get the user info for checkouts on other branches */
	@:thisConst function GetOtherUserBranchCheckedOuts() : FString;

	/** Get head modification information for other branches
	 * @returns true with parameters populated if there is a branch with a newer modification (edit/delete/etc)
	 */
	@:thisConst function GetOtherBranchHeadModification(HeadBranchOut:PRef<FString>, ActionOut:PRef<FString>, HeadChangeListOut:PRef<Int32>) : Bool;

	/** Get whether this file is up-to-date with the version in source control */
	@:thisConst function IsCurrent() : Bool;

	/** Get whether this file is under source control */
	@:thisConst function IsSourceControlled() : Bool;

	/** Get whether this file is marked for add */
	@:thisConst function IsAdded() : Bool;

	/** Get whether this file is marked for delete */
	@:thisConst function IsDeleted() : Bool;

	/** Get whether this file is ignored by source control */
	@:thisConst function IsIgnored() : Bool;

	/** Get whether source control allows this file to be edited */
	@:thisConst function CanEdit() : Bool;

	/** Get whether source control allows this file to be deleted. */
	@:thisConst function CanDelete() : Bool;

	/** Get whether we know anything about this files source control state */
	@:thisConst function IsUnknown() : Bool;

	/** Get whether this file is modified compared to the version we have from source control */
	@:thisConst function IsModified() : Bool;

	/**
	 * Get whether this file can be added to source control (i.e. is part of the directory
	 * structure currently under source control)
	 */
	@:thisConst function CanAdd() : Bool;

	/** Get whether this file is in a conflicted state */
	@:thisConst function IsConflicted() : Bool;

	/** Get whether this file can be reverted, i.e. its changes are discarded and the file will no longer be checked-out. */
	@:thisConst function CanRevert() : Bool;
}
