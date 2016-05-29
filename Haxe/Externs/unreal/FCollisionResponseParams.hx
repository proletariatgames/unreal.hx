package unreal;

@:glueCppIncludes("CollisionQueryParams.h")
@:uextern extern class FCollisionResponseParams {
  @:uname(".ctor") static function create():FCollisionResponseParams;
  static var DefaultResponseParam(default, never):FCollisionResponseParams;
}
