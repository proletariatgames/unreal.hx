package unreal;

@:glueCppIncludes("WorldCollision.h")
@:uextern extern class FCollisionShape {
  static function MakeCapsule(CapsuleRadius:Float32, CapsuleHalfHeight:Float32):FCollisionShape;
}
