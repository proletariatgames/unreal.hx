package unreal;

@:hasEquals
extern class FGuid_Extra {
  @:uname('new')
  static public function create() : PHaxeCreated<FGuid>;

  static public function NewGuid() : FGuid;

  @:thisConst
  public function ToString() : FString;
}
