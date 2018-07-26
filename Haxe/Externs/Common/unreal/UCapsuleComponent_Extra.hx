package unreal;

extern class UCapsuleComponent_Extra {
	/**
    Returns the capsule radius and half-height scaled by the component scale. Half-height includes the hemisphere end cap.
    @param OutRadius Radius of the capsule, scaled by the component scale.
    @param OutHalfHeight Half-height of the capsule, scaled by the component scale. Includes the hemisphere end cap.
    @return The capsule radius and half-height scaled by the component scale.
  **/
  @:ureplace public function GetUnscaledCapsuleSize(OutRadius : Ref<unreal.Float32>, OutHalfHeight : Ref<unreal.Float32>) : Void;
}
