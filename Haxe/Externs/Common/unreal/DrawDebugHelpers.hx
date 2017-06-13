package unreal;

@:glueCppIncludes("DrawDebugHelpers.h")
@:noCopy @:noEquals
@:uextern extern class DrawDebugHelpers {
  @:glueCppIncludes("DrawDebugHelpers.h")
  @:global public static function DrawDebugSphere(InWorld:UWorld, Center:Const<PRef<FVector>>, Radius:Float32, Segments:Int32, Color:Const<PRef<FColor>>, bPersistentLines:Bool /* = false */, LifeTime:Float32 /* = -1.f */, DepthPriority:UInt8 /* = 0 */):Void;
}