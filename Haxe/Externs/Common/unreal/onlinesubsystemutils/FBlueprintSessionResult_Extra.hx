package unreal.onlinesubsystemutils;

extern class FBlueprintSessionResult_Extra {
  @:uname('.ctor')
  static public function create() : FBlueprintSessionResult;
  @:uname('new')
  static public function createNew() : POwnedPtr<FBlueprintSessionResult>;

  public var OnlineResult : FOnlineSessionSearchResult;
}
