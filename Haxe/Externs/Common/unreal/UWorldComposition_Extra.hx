package unreal;

extern class UWorldComposition_Extra {
	/** Adds or removes level streaming objects to world based on distance settings from current view point */
	public function UpdateStreamingState(InLocation:Const<PRef<FVector>>):Void;
}