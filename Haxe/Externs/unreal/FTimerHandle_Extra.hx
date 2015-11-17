package unreal;

extern class FTimerHandle_Extra
{
  @:uname("new")
  static function create() : PHaxeCreated<FTimerHandle>;

  @:thisConst function IsValid() : Bool;
  function Invalidate() : Void;
  function MakeValid() : Void;
  function ToString() : FString;
}
