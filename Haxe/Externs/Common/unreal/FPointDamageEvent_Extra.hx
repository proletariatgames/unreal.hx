package unreal;

extern class FPointDamageEvent_Extra {
  @:uname(".ctor")
  public static function create() : FPointDamageEvent;
  @:uname("new")
  public static function createNew() : POwnedPtr<FPointDamageEvent>;
  public static var ClassID(get,never) : Int32;
}
