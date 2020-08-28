package unreal;

@:hasEquals
extern class FPrimaryAssetType_Extra {
	@:uname(".ctor") public static function create(InName:FName):FPrimaryAssetType;

	@:thisConst
	public function ToString() : FString;

	@:thisConst
	public function IsValid():Bool;

  @:expr(return ToString().toString())
  public function toString():String;
}
