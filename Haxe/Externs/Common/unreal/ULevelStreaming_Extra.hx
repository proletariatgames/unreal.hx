package unreal;

extern class ULevelStreaming_Extra {
	/** Returns whether the streaming level is in the loading state. */
	@:thisConst
	public function HasLoadRequestPending():Bool;
	/** Gets a pointer to the LoadedLevel value */
	@:thisConst
	public function GetLoadedLevel() : ULevel;
}