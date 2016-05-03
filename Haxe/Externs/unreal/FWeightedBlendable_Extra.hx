package unreal;

extern class FWeightedBlendable_Extra {
  @:uname(".ctor")
  public static function create() : FWeightedBlendable;
  @:uname("new")
  public static function createNew() : POwnedPtr<FWeightedBlendable>;

  @:uname(".ctor")
  public static function createWithParams(weight:Float32, blendable:UObject) : FWeightedBlendable;
  @:uname("new")
  public static function createNewWithParams(weight:Float32, blendable:UObject) : POwnedPtr<FWeightedBlendable>;
}
