package unreal;

extern class APlayerCameraManager_Extra {
  function UpdateCamera(DeltaTime:Float32) : Void;

	/**
	 * Sets a new ViewTarget.
	 * @param NewViewTarget - New viewtarget actor.
	 * @param TransitionParams - Optional parameters to define the interpolation from the old viewtarget to the new. Transition will be instant by default.
	 */
	function SetViewTarget(NewViewTarget:AActor, TransitionParams : FViewTargetTransitionParams) : Void;
}
