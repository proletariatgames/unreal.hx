package unreal;

@:hasEquals
extern class FGuid_Extra {
  public var A:UInt32;
  public var B:UInt32;
  public var C:UInt32;
  public var D:UInt32;

  @:uname('.ctor')
  static public function create() : FGuid;
  @:uname('new')
  static public function createNew() : POwnedPtr<FGuid>;

  static public function NewGuid() : FGuid;

  @:thisConst
  public function ToString() : FString;
}
