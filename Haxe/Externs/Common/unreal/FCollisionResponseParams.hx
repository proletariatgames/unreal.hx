package unreal;

@:glueCppIncludes("CollisionQueryParams.h")
@:uextern extern class FCollisionResponseParams {
  public function new(DefaultResponse:ECollisionResponse = ECR_Block);
  @:uname(".ctor") static function create(DefaultResponse:ECollisionResponse = ECR_Block):FCollisionResponseParams;
  @:uname(".ctor") static function createFromResponseContainer(container:Const<PRef<FCollisionResponseContainer>>):FCollisionResponseParams;
  static var DefaultResponseParam(default, never):FCollisionResponseParams;
  var CollisionResponse:FCollisionResponseContainer;
}
