package unreal;

@:hasEquals
extern class FPrimaryAssetId_Extra {
	/** An FName describing the logical type of this object, usually the name of a base UClass. For example, any Blueprint derived from APawn will have a Primary Asset Type of "Pawn".
	"PrimaryAssetType:PrimaryAssetName" should form a unique name across your project. */
	public var PrimaryAssetType:FPrimaryAssetType;

	/** An FName describing this asset. This is usually the short name of the object, but could be a full asset path for things like maps, or objects with GetPrimaryId() overridden.
	"PrimaryAssetType:PrimaryAssetName" should form a unique name across your project. */
	public var PrimaryAssetName:FName;

	/** Returns true if this is a valid identifier */
	@:thisConst public function IsValid() : Bool;

	/** Returns string version of this identifier in Type:Name format */
	@:thisConst public function ToString() : FString;

	/** Converts from Type:Name format */
	public static function FromString(Str:FString) : FPrimaryAssetId;
}
