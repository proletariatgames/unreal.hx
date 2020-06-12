package unreal.animationbudgetallocator;

extern class USkeletalMeshComponentBudgeted_Extra
{
	/** Updates significance budget if this component has been registered with a AnimationBudgetAllocator */
	public function SetComponentSignificance(Significance:Float32, bNeverSkip:Bool = false, bTickEvenIfNotRendered:Bool = false, bAllowReducedWork:Bool = true, bForceInterpolate:Bool = false) : Void;
}
