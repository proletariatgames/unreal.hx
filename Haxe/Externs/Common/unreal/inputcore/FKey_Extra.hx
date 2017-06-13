package unreal.inputcore;

extern class FKey_Extra {
  @:uname(".ctor")
  public static function create() : FKey;
  @:uname(".ctor")
  public static function createByName(InName:FName) : FKey;
  public function GetDisplayName() : FText;
  public function GetFName() : FName;
  public function IsGamepadKey() : Bool;
  public function ToString() : FString;
}