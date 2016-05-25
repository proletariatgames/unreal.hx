package unreal;

@:hasEquals
extern class FTimerHandle_Extra
{
  @:uname(".ctor")
  static function create() : FTimerHandle;
  @:uname("new")
  static function createNew() : POwnedPtr<FTimerHandle>;

  @:thisConst function IsValid() : Bool;
  function Invalidate() : Void;
  function ToString() : FString;
}
