package unreal;

extern class FWeightedBlendable_Extra {
  @:uname("new")
  public static function create() : POwnedPtr<FWeightedBlendable>;

  @:uname("new")
  public static function createWithParams(weight:Float32, blendable:UObject) : POwnedPtr<FWeightedBlendable>;
}
