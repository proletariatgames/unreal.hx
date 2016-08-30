package unreal;

@:glueCppIncludes("CollisionQueryParams.h")
@:uextern extern class FCollisionResponseParams {
  @:uname(".ctor") static function create():FCollisionResponseParams;
  @:uname(".ctor") static function createFromResponseContainer(container:Const<PRef<FCollisionResponseContainer>>):FCollisionResponseParams;
  static var DefaultResponseParam(default, never):FCollisionResponseParams;
}
