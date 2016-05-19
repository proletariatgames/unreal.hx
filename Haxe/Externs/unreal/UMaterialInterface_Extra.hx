package unreal;

extern class UMaterialInterface_Extra {
	/** Walks up parent chain and finds the base Material that this is an instance of. Just calls the virtual GetMaterial() */
	public function GetBaseMaterial() : UMaterial;
}