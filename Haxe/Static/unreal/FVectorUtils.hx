package unreal;

class FVectorUtils {
#if (!bake_externs && !macro)

  // Add FVector b to FVector a. Return a.
  public static function addeq(a:unreal.FVector,b:unreal.FVector) {
    if (a != null && b != null) {
      a.X += b.X;
      a.Y += b.Y;
      a.Z += b.Z;
    }
    return a;
  }

  // Subtract FVector b from FVector a. Return a.
  public static function subeq(a:unreal.FVector,b:unreal.FVector) {
    if (a != null && b != null) {
      a.X -= b.X;
      a.Y -= b.Y;
      a.Z -= b.Z;
    }
    return a;
  }

  // Multiply FVector a by scalar Float32 f. Vector a is modified.
  public static function muleq(a:unreal.FVector,f:Float32) {
    if (a != null) {
      a.X *= f;
      a.Y *= f;
      a.Z *= f;
    }
    return a;
  }

  // Return scalar value that is dot product of 
  public static function dot(a:unreal.FVector,b:unreal.FVector) {
    var result:Float32 = 0;
    if (a != null && b != null) {
      result = (a.X*b.X) + (a.Y*b.Y) + (a.Z*b.Z);
    }
    return result;
  }

  // Return newly allocated vector that is cross product of a and b.
  public static function cross(a:unreal.FVector, b:unreal.FVector) {
    var result = unreal.FVector.createWithValues(0,0,0);
    if (a != null && b != null) {
      result.X = a.Y*b.Z - a.Z*b.Y;
      result.Y = a.X*b.Z - a.Z*b.X;
      result.Z = a.X*b.Y - a.Y*b.X;
    }
    return result;
  }

  // zero out a vector
  public static function zero(a:unreal.FVector) {
    if (a != null) {
      a.X = 0;
      a.Y = 0;
      a.Z = 0;
    }
  }
#end // (!bake_externs && !macro)
}