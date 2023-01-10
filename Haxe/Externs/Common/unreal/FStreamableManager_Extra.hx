package unreal;

@:noCopy
extern class FStreamableManager_Extra {

	/**
	 * This is the primary streamable operation. Requests streaming of one or more target objects. When complete, a delegate function is called. Returns a Streamable Handle.
	 *
	 * @param TargetsToStream		Assets to load off disk
	 * @param DelegateToCall		Delegate to call when load finishes. Will be called on the next tick if asset is already loaded, or many seconds later
	 * @param Priority				Priority to pass to the streaming system, higher priority will be loaded first
	 * @param bManageActiveHandle	If true, the manager will keep the streamable handle active until explicitly released
	 * @param bStartStalled			If true, the handle will start in a stalled state and will not attempt to actually async load until StartStalledHandle is called on it
	 * @param DebugName				Name of this handle, will be reported in debug tools
	 */
	@:uname("RequestAsyncLoad")
	public function AsyncLoadPaths(TargetsToStream: Const<PRef<TArray<FSoftObjectPath>>>, DelegateToCall:FStreamableDelegate):TSharedPtr<FStreamableHandle>;

	/**
	 * This is the primary streamable operation. Requests streaming of one or more target objects. When complete, a delegate function is called. Returns a Streamable Handle.
	 *
	 * @param TargetToStream		Asset to load off disk
	 * @param DelegateToCall		Delegate to call when load finishes. Will be called on the next tick if asset is already loaded, or many seconds later
	 * @param Priority				Priority to pass to the streaming system, higher priority will be loaded first
	 * @param bManageActiveHandle	If true, the manager will keep the streamable handle active until explicitly released
	 * @param bStartStalled			If true, the handle will start in a stalled state and will not attempt to actually async load until StartStalledHandle is called on it
	 * @param DebugName				Name of this handle, will be reported in debug tools
	 */
	@:uname("RequestAsyncLoad")
	public function AsyncLoadPath(TargetToStream: Const<PRef<FSoftObjectPath>>, DelegateToCall:FStreamableDelegate):TSharedPtr<FStreamableHandle>;

}
