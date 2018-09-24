package unreal;

extern class AVolume_Extra {

  /** @returns true if a sphere/point (with optional radius CheckRadius) overlaps this volume */
  public function EncompassesPoint(point:FVector, sphereRadius:Float32, OutDistanceToPoint:Ptr<Float32>) : Bool;
}
