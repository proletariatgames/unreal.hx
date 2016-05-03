package unreal;

extern class FVector_NetQuantizeNormal_Extra {
  @:uname(".ctor")
  public static function fromVector(vec:Const<PRef<FVector>>) : FVector_NetQuantizeNormal;
  @:uname("new")
  public static function fromVectorNew(vec:Const<PRef<FVector>>) : POwnedPtr<FVector_NetQuantizeNormal>;
}

