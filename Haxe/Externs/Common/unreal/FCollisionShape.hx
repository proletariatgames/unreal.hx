package unreal;

@:glueCppIncludes("WorldCollision.h")
@:uextern extern class FCollisionShape {
  static function MakeBox(BoxHalfExtent:Const<PRef<FVector>>):FCollisionShape;
  static function MakeSphere(SphereRadius:Float32):FCollisionShape;
  static function MakeCapsule(CapsuleRadius:Float32, CapsuleHalfHeight:Float32):FCollisionShape;
}
