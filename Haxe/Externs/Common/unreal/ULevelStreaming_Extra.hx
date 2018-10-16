package unreal;

extern class ULevelStreaming_Extra {
	/** Returns whether the streaming level is in the loading state. */
	@:thisConst
	public function HasLoadRequestPending():Bool;
}