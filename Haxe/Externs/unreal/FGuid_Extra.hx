package unreal;

extern class FGuid_Extra {
  @:uname('new')
  static public function create() : PHaxeCreated<FGuid>;

  @:thisConst
  public function ToString() : FString;
}
