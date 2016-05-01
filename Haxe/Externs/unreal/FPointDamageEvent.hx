package unreal;

@:glueCppIncludes("Engine/EngineTypes.h")
@:uextern extern class FPointDamageEvent extends FDamageEvent {
  @:uname("new")
  public static function create() : POwnedPtr<FPointDamageEvent>;
  public static var ClassID(get,never) : Int32;

  public var HitInfo:FHitResult;
  public var Damage:Float32;
  public var ShotDirection:FVector_NetQuantizeNormal;
}
