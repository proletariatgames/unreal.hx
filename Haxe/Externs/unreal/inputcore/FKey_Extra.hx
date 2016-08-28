package unreal.inputcore;

extern class FKey_Extra {
  @:uname(".ctor")
  public static function create() : FKey;
  public function GetDisplayName() : FText;
  public function GetFName() : FName;
  public function IsGamepadKey() : Bool;
  public function ToString() : FString;
}