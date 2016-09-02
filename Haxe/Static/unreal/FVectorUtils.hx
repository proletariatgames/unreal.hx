package unreal;

class FVectorUtils {
#if (!bake_externs && !macro)

  // Add FVector b to FVector a. Return a.
  public static inline function addeq(a:unreal.FVector,b:unreal.FVector) {
    a.X += b.X;
    a.Y += b.Y;
    a.Z += b.Z;
    return a;
  }

  // Subtract FVector b from FVector a. Return a.
  public static inline function subeq(a:unreal.FVector,b:unreal.FVector) {
    a.X -= b.X;
    a.Y -= b.Y;
    a.Z -= b.Z;
    return a;
  }

  // Multiply FVector a by scalar Float32 f. Vector a is modified.
  public static inline function muleq(a:unreal.FVector,f:Float32) {
    a.X *= f;
    a.Y *= f;
    a.Z *= f;
    return a;
  }

  public static inline function distance(a:unreal.FVector,b:unreal.FVector) : Float32 {
    return Math.sqrt(Math.pow(a.X - b.X, 2) + Math.pow(a.Y - b.Y, 2) + Math.pow(a.Z - b.Z, 2));
  }

  // Return scalar value that is dot product of
  public static inline function dot(a:unreal.FVector,b:unreal.FVector) : Float32 {
    return (a.X*b.X) + (a.Y*b.Y) + (a.Z*b.Z);
  }

  // Return newly allocated vector that is cross product of a and b.
  public static function cross(a:unreal.FVector, b:unreal.FVector, ?result:unreal.FVector) : unreal.FVector {
    if (result == null) {
      result = unreal.FVector.createWithValues(0,0,0);
    }
    result.X = a.Y*b.Z - a.Z*b.Y;
    result.Y = a.X*b.Z - a.Z*b.X;
    result.Z = a.X*b.Y - a.Y*b.X;
    return result;
  }

  // zero out a vector
  public static function zero(a:unreal.FVector) {
    a.X = 0;
    a.Y = 0;
    a.Z = 0;
  }
#end // (!bake_externs && !macro)
}
