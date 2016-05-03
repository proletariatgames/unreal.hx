package unreal;

@:hasEquals
extern class FGuid_Extra {
  @:uname('.ctor')
  static public function create() : FGuid;
  @:uname('new')
  static public function createNew() : POwnedPtr<FGuid>;

  static public function NewGuid() : FGuid;

  @:thisConst
  public function ToString() : FString;
}
