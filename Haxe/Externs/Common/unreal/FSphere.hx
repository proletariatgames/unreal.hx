package unreal;

@:glueCppIncludes("Sphere.h")
@:uextern extern class FSphere {
  public var Center:FVector;
  public var W:Float32;

  @:uname('.ctor')
  public static function createForceInit(ForceInit:EForceInit) : FSphere;
  @:uname('new')
  public static function createNewForceInit(ForceInit:EForceInit) : POwnedPtr<FSphere>;
  @:uname('.ctor')
  public static function create(InV:FVector, InW:Float32) : FSphere;
  @:uname('new')
  public static function createNew(InV:FVector, InW:Float32) : POwnedPtr<FSphere>;
}

