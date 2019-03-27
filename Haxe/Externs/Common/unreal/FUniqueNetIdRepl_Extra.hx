package unreal;

@:hasCopy @:hasEquals
extern class FUniqueNetIdRepl_Extra {
	@:uname('.ctor')
	public static function create() : FUniqueNetIdRepl;

	@:uname('.ctor')
	public static function createFromWrapper(InWrapper : Const<PRef<FUniqueNetIdWrapper>>) : FUniqueNetIdRepl;

	@:uname('.ctor')
	public static function createFromIdRef(InUniqueNetId : Const<PRef<TSharedRef<Const<FUniqueNetId>>>>) : FUniqueNetIdRepl;

	@:uname('.ctor')
	public static function createFromIdPtr(InUniqueNetId : Const<PRef<TSharedPtr<Const<FUniqueNetId>>>>) : FUniqueNetIdRepl;
}
