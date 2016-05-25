package unreal;

@:glueCppIncludes('unreal/FixedFindSessionsCallbackProxy.h')
@:uname("FBlueprintSessionResult")
@:ustruct
@:uextern extern class FBlueprintSessionResult {

	@:uname('.ctor')
	static public function create() : FBlueprintSessionResult;
	@:uname('new')
	static public function createNew() : POwnedPtr<FBlueprintSessionResult>;

	public var OnlineResult : FOnlineSessionSearchResult;
}
