package unreal;

@:hasEquals @:hasCopy
extern class FUniqueNetIdWrapper_Extra {
	@:uname('.ctor')
	public static function create() : FUniqueNetIdWrapper;

	@:uname('.ctor')
	public static function createFromIdRef(InUniqueNetId : Const<PRef<TSharedRef<Const<FUniqueNetId>>>>) : FUniqueNetIdWrapper;

	@:uname('.ctor')
	public static function createFromIdPtr(InUniqueNetId : Const<PRef<TSharedPtr<Const<FUniqueNetId>>>>) : FUniqueNetIdWrapper;

	@:thisConst public function ToString() : FString;

	@:thisConst public function ToDebugString() : FString;

	@:thisConst public function IsValid() : Bool;

	public function SetUniqueNetId(InUniqueNetId : Const<PRef<TSharedPtr<Const<FUniqueNetId>>>>) : Void;

	@:thisConst public function GetUniqueNetId() : Const<PRef<TSharedPtr<Const<FUniqueNetId>>>>;
}
