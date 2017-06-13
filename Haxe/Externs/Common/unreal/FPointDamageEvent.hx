package unreal;

@:glueCppIncludes("Engine/EngineTypes.h")
@:uextern extern class FPointDamageEvent extends FDamageEvent {
  @:uname(".ctor")
  public static function create() : FPointDamageEvent;
  @:uname("new")
  public static function createNew() : POwnedPtr<FPointDamageEvent>;
  public static var ClassID(get,never) : Int32;

  public var HitInfo:FHitResult;
  public var Damage:Float32;
  public var ShotDirection:FVector_NetQuantizeNormal;
}
