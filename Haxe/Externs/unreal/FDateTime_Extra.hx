package unreal;

extern class FDateTime_Extra {

  @:thisConst @:uname("ToString")
  public function toString() : FString;

  @:thisConst @:uname("ToString")
  public function toFormattedString(fmt:TCharStar) : FString;

  @:thisConst
  public function ToUnixTimestamp() : Int64;

  public static function FromUnixTimestamp(unixTime:Int64) : FDateTime;

  public function GetDate() : FDateTime;
}
