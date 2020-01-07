package unreal;

@:glueCppIncludes("Engine/Classes/Engine/StreamableManager.h")
@:noCopy @:noEquals
@:uextern extern class FStreamableHandle {
	/**
	 * If this request has finished loading, meaning all available assets were loaded
	 * Any assets that failed to load will still be null
	 * This can be true before the completion callback has happened as it may be in the delayed callback queue
	 */
	@:thisConst
	public function HasLoadCompleted() : Bool;


	/** If this request was cancelled. Assets may still have been loaded, but completion delegate was not called */
	@:thisConst
	public function WasCanceled() : Bool;

	/** True if load is still ongoing and we haven't been cancelled */
	@:thisConst
	public function IsLoadingInProgress() : Bool;

	/** If this handle is still active, meaning it wasn't canceled or released */
	@:thisConst
	public function IsActive() : Bool;

	/** If this handle is stalled and waiting for another event to occur before it is actually requested */
	@:thisConst
	public function IsStalled() : Bool;

	/** Returns true if this is a combined handle that depends on child handles. */
	@:thisConst
	public function IsCombinedHandle() : Bool;

	/** Returns true if we've done all the loading we can now, ie all handles are either completed or stalled */
	@:thisConst
	public function HasLoadCompletedOrStalled() : Bool;

	/** Returns the debug name for this handle. */
	@:thisConst
	public function GetDebugName() : PRef<Const<FString>>;

	/**
	 * Release this handle. This can be called from normal gameplay code to indicate that the loaded assets are no longer needed
	 * This will be called implicitly if all shared pointers to this handle are destroyed
	 * If called before the completion delegate, the release will be delayed until after completion
	 */
	public function ReleaseHandle() : Void;

	/**
	 * Cancel a request, callable from within the manager or externally
	 * This will immediately release the handle even if it is still in progress, and call the cancel callback if bound
	 * This stops the completion callback from happening, even if it is in the delayed callback queue
	 */
	public function CancelHandle() : Void;

	/** Tells a stalled handle to start its actual request. */
	public function StartStalledHandle() : Void;

	/** Bind delegate that is called when load completes, only works if loading is in progress. This will overwrite any already bound delegate! */
	public function BindCompleteDelegate(NewDelegate:FStreamableDelegate) : Bool;

	/** Bind delegate that is called if handle is canceled, only works if loading is in progress. This will overwrite any already bound delegate! */
	public function BindCancelDelegate(NewDelegate:FStreamableDelegate) : Bool;

	/** Gets list of assets references this load was started with. This will be the paths before redirectors, and not all of these are guaranteed to be loaded */
	@:thisConst
	public function GetRequestedAssets(AssetList:PRef<TArray<FSoftObjectPath>>) : Void;

	/** Adds all loaded assets if load has succeeded. Some entries will be null if loading failed */
	@:thisConst
	public function GetLoadedAssets(LoadedAssets:PRef<TArray<UObject>>) : Void;

	/** Returns first asset in requested asset list, if it's been successfully loaded. This will fail if the asset failed to load */
	@:thisConst
	public function GetLoadedAsset() : UObject;

	/** Returns number of assets that have completed loading out of initial list, failed loads will count as loaded */
	@:thisConst
	public function GetLoadedCount(LoadedCount:Ref<Int32>, RequestedCount:Ref<Int32>) : Void;

	/** Returns progress as a value between 0.0 and 1.0. */
	@:thisConst
	public function GetProgress() : Float32;
}
