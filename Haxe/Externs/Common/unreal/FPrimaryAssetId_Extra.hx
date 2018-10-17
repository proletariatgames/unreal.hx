package unreal;

@:hasEquals
extern class FPrimaryAssetId_Extra {
	public static function FromString(Str:FString) : FPrimaryAssetId;
	public function ToString() : FString;
}