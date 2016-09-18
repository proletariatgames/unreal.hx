package unreal;

extern class FDateTime_Extra {

  @:thisConst @:uname("ToString")
  public function toString() : FString;

  @:thisConst
  public function ToUnixTimestamp() : Int64;

}
