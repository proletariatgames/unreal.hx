package unreal;

extern class UParticleSystemComponent_Extra {
  public function DeactivateSystem() : Void;

  /**
   *	Retrieve the Float parameter value for the given name.
   *
   *	@param	InName		Name of the parameter
   *	@param	OutFloat	The value of the parameter found
   *
   *	@return	true		Parameter was found - OutFloat is valid
   *			false		Parameter was not found - OutFloat is invalid
   */
  public function GetFloatParameter(InName:Const<FName>, OutFloat:Ref<Float32>) : Bool;
  public var bAutoDestroy:Bool;
}
