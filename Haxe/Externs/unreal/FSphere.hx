package unreal;

@:glueCppIncludes("Sphere.h")
@:uextern extern class FSphere {
  public var Center:FVector;
  public var W:Float32;

  @:uname('new')
  public static function createForceInit(ForceInit:EForceInit) : PHaxeCreated<FSphere>;
  @:uname('new')
  public static function create(InV:FVector, InW:Float32) : PHaxeCreated<FSphere>;
}

