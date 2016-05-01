package unreal;

@:hasEquals
extern class FGuid_Extra {
  @:uname('new')
  static public function create() : POwnedPtr<FGuid>;

  static public function NewGuid() : FGuid;

  @:thisConst
  public function ToString() : FString;
}
