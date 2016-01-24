package unreal;

extern class FWeightedBlendable_Extra {
  @:uname("new")
  public static function create() : PHaxeCreated<FWeightedBlendable>;

  @:uname("new")
  public static function createWithParams(weight:Float32, blendable:UObject) : PHaxeCreated<FWeightedBlendable>;
}
