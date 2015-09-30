package unreal;

@:glueCppIncludes("Math/Vector.h")
@:uextern extern class FVector {
  var X:Float32;
  var Y:Float32;
  var Z:Float32;

  @:uname('new') static function create():PHaxeCreated<FVector>;
  @:uname('new') static function createWithValues(x:Float32,y:Float32,z:Float32):PHaxeCreated<FVector>;
  function Size():Float32;
}
