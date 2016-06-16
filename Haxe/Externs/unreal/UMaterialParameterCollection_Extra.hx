package unreal;


extern class UMaterialParameterCollection_Extra {
	/** Utility to find a scalar parameter struct given a parameter name.  Returns NULL if not found. */
  @:thisConst
  function GetScalarParameterByName(ParameterName:FName) : Const<PPtr<FCollectionScalarParameter>>;

	/** Utility to find a vector parameter struct given a parameter name.  Returns NULL if not found. */
  @:thisConst
	function GetVectorParameterByName(ParameterName:FName) : Const<PPtr<FCollectionVectorParameter>>;
}